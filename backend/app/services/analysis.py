import os
import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from sklearn.model_selection import train_test_split, KFold
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.ensemble import RandomForestClassifier

# --- 1. Config ---


class Config:
    FILE_NAME = 'Anxiety_Disorders_Dataset_20000.csv'
    BATCH_SIZE = 128
    LR = 0.001
    EPOCHS = 100
    DROPOUT = 0.3
    HIDDEN_SIZE = 192
    PATIENCE = 10
    NOISE_STD = 0.3
    RANDOM_STATE = 42
    MODEL_PATH = "best_anxiety_transformer.pth"

# --- 2. Data Preprocessing ---


def load_and_preprocess():
    if not os.path.exists(Config.FILE_NAME):
        raise FileNotFoundError(f"{Config.FILE_NAME} not found.")
    df = pd.read_csv(Config.FILE_NAME)
    df = df.dropna(subset=['Diagnosis'])
    le = LabelEncoder()
    df['Diagnosis'] = le.fit_transform(df['Diagnosis'])
    num_classes = len(le.classes_)

    feature_cols = [
        'Age', 'Gender', 'Family_History',
        'Q1_Feeling_Nervous', 'Q2_Cant_Stop_Worrying', 'Q3_Too_Much_Worry',
        'Q4_Trouble_Relaxing', 'Q5_Restless', 'Q6_Irritable', 'Q7_Fear_Something_Awful',
        'Heart_Racing', 'Sweating', 'Sleep_Problems', 'Concentration_Problems', 'Panic_Attacks'
    ]
    X = df[feature_cols].values.astype(float)
    y = df['Diagnosis'].values

    if Config.NOISE_STD > 0:
        noise = np.random.normal(0, Config.NOISE_STD, X.shape)
        X += noise
        X = np.round(X).clip(0, 3)

    scaler = StandardScaler()
    X = scaler.fit_transform(X)

    return X, y, num_classes, le, feature_cols

# --- 3. Dataset ---


class AnxietyDataset(Dataset):
    def __init__(self, X, y):
        self.X = torch.tensor(X, dtype=torch.float32)
        self.y = torch.tensor(y, dtype=torch.long)

    def __len__(self): return len(self.y)
    def __getitem__(self, idx): return self.X[idx], self.y[idx]

# --- 4. Positional Encoding ---


class PositionalEncoding(nn.Module):
    def __init__(self, d_model, max_len=100):
        super().__init__()
        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len).unsqueeze(1)
        div_term = torch.exp(torch.arange(0, d_model, 2)
                             * (-math.log(10000.0)/d_model))
        pe[:, 0::2] = torch.sin(position*div_term)
        pe[:, 1::2] = torch.cos(position*div_term)
        pe = pe.unsqueeze(0)
        self.register_buffer('pe', pe)

    def forward(self, x): return x + self.pe[:, :x.size(1)]

# --- 5. Transformer Model ---


class AnxietyTransformer(nn.Module):
    def __init__(self, input_size, num_classes):
        super().__init__()
        self.embedding_dim = 32
        self.embedding = nn.Linear(1, self.embedding_dim)
        self.positional_encoding = PositionalEncoding(self.embedding_dim)
        encoder_layer = nn.TransformerEncoderLayer(
            d_model=self.embedding_dim, nhead=4, dim_feedforward=128,
            dropout=Config.DROPOUT, batch_first=True
        )
        self.transformer = nn.TransformerEncoder(encoder_layer, num_layers=2)
        self.fc = nn.Linear(self.embedding_dim, num_classes)

    def forward(self, x):
        x = x.unsqueeze(-1)
        x = self.embedding(x)
        x = self.positional_encoding(x)
        x = self.transformer(x)
        x = x.mean(dim=1)
        return self.fc(x)

# --- 6. Training with Early Stopping & Class Weights ---


def train_model(model, train_loader, val_loader, device, class_weights=None):
    criterion = nn.CrossEntropyLoss(weight=class_weights)
    optimizer = optim.Adam(model.parameters(), lr=Config.LR)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, 'min', factor=0.5, patience=5)

    best_val_loss = float('inf')
    patience_counter = 0
    train_losses, val_losses = [], []

    for epoch in range(Config.EPOCHS):
        model.train()
        total_train = 0
        for X_batch, y_batch in train_loader:
            X_batch, y_batch = X_batch.to(device), y_batch.to(device)
            optimizer.zero_grad()
            outputs = model(X_batch)
            loss = criterion(outputs, y_batch)
            loss.backward()
            optimizer.step()
            total_train += loss.item()
        avg_train = total_train / len(train_loader)
        train_losses.append(avg_train)

        model.eval()
        total_val = 0
        with torch.no_grad():
            for X_batch, y_batch in val_loader:
                X_batch, y_batch = X_batch.to(device), y_batch.to(device)
                outputs = model(X_batch)
                loss = criterion(outputs, y_batch)
                total_val += loss.item()
        avg_val = total_val / len(val_loader)
        val_losses.append(avg_val)
        scheduler.step(avg_val)

        print(
            f"Epoch [{epoch+1}/{Config.EPOCHS}] Train Loss: {avg_train:.4f} | Val Loss: {avg_val:.4f}")

        if avg_val < best_val_loss:
            best_val_loss = avg_val
            torch.save(model.state_dict(), Config.MODEL_PATH)
            patience_counter = 0
        else:
            patience_counter += 1
            if patience_counter >= Config.PATIENCE:
                print(f"🛑 Early stopping at epoch {epoch+1}")
                break
    return train_losses, val_losses

# --- 7. Evaluation + Confusion Matrix ---


def evaluate(model, test_loader, device, le):
    model.eval()
    y_pred, y_true = [], []
    with torch.no_grad():
        for X_batch, y_batch in test_loader:
            X_batch = X_batch.to(device)
            outputs = model(X_batch)
            preds = torch.argmax(outputs, dim=1).cpu().numpy()
            y_pred.extend(preds)
            y_true.extend(y_batch.numpy())

    acc = accuracy_score(y_true, y_pred)
    print("\n" + "="*60)
    print(f"Final Accuracy: {acc*100:.2f}%")
    print(classification_report(y_true, y_pred,
          target_names=[str(c) for c in le.classes_]))
    print("="*60)

    # Confusion Matrix
    cm = confusion_matrix(y_true, y_pred)
    plt.figure(figsize=(6, 5))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues")
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.title("Confusion Matrix")
    plt.show()

# --- 8. Feature Importance (RandomForest) ---


def feature_importance(X, y, feature_cols):
    rf = RandomForestClassifier(
        n_estimators=100, random_state=Config.RANDOM_STATE)
    rf.fit(X, y)
    importances = rf.feature_importances_
    plt.figure(figsize=(10, 5))
    plt.barh(feature_cols, importances)
    plt.title("Feature Importance (RandomForest)")
    plt.show()

# --- 9. Main ---


def main():
    X, y, num_classes, le, feature_cols = load_and_preprocess()

    # Split
    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.3, random_state=Config.RANDOM_STATE, stratify=y
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.5, random_state=Config.RANDOM_STATE, stratify=y_temp
    )

    # Class weights
    class_counts = np.bincount(y_train)
    class_weights = 1.0 / class_counts
    class_weights = torch.tensor(class_weights, dtype=torch.float32)

    # DataLoaders
    train_loader = DataLoader(AnxietyDataset(
        X_train, y_train), batch_size=Config.BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(AnxietyDataset(X_val, y_val),
                            batch_size=Config.BATCH_SIZE, shuffle=False)
    test_loader = DataLoader(AnxietyDataset(
        X_test, y_test), batch_size=Config.BATCH_SIZE, shuffle=False)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    model = AnxietyTransformer(
        input_size=X.shape[1], num_classes=num_classes).to(device)

    train_losses, val_losses = train_model(
        model, train_loader, val_loader, device, class_weights=class_weights.to(device))

    # Load best model
    model.load_state_dict(torch.load(Config.MODEL_PATH))

    # Evaluate
    evaluate(model, test_loader, device, le)

    # Feature importance
    feature_importance(X, y, feature_cols)

    # Loss plot
    plt.figure(figsize=(10, 5))
    plt.plot(train_losses, label="Train Loss")
    plt.plot(val_losses, label="Val Loss")
    plt.title("Training vs Validation Loss")
    plt.xlabel("Epochs")
    plt.ylabel("Loss")
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
