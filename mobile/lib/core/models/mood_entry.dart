class MoodEntry {
  final String userId;
  final int mood; // 1 = sad, 2 = neutral, 3 = happy
  final DateTime date;

  MoodEntry({required this.userId, required this.mood, required this.date});

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "mood": mood,
    "date": date.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      userId: json["userId"],
      mood: json["mood"],
      date: DateTime.parse(json["date"]),
    );
  }
}
