import os
import sys
import subprocess
import platform
import shutil

ROOT = os.path.dirname(os.path.abspath(__file__))

BACKEND_DIR = os.path.join(ROOT, "backend")
API_DIR = os.path.join(BACKEND_DIR, "app", "api")
MOBILE_DIR = os.path.join(ROOT, "mobile")

REQUIREMENTS = os.path.join(BACKEND_DIR, "requirements.txt")

OPENROUTER_KEY = "YOUR_API_KEY"

IS_WINDOWS = platform.system() == "Windows"


def run(cmd, cwd=None):
    try:
        subprocess.check_call(cmd, cwd=cwd, shell=True)
    except subprocess.CalledProcessError as e:
        print("Command failed:", cmd)
        print(e)


def command_exists(cmd):
    return shutil.which(cmd) is not None


def ensure_python_deps():
    print("Checking Python dependencies...")

    if not command_exists("python") and not command_exists("python3"):
        print("Python is not installed.")
        sys.exit(1)

    if os.path.exists(REQUIREMENTS):
        print("Installing requirements.txt...")
        run(f"{sys.executable} -m pip install -r {REQUIREMENTS}")
    else:
        print("requirements.txt not found")


def ensure_flutter():
    print("Checking Flutter...")

    if not command_exists("flutter"):
        print("Flutter is not installed or not in PATH")
        sys.exit(1)

    pubspec = os.path.join(MOBILE_DIR, "pubspec.yaml")

    if not os.path.exists(pubspec):
        print("Flutter project not initialized. Running flutter create .")
        run("flutter create .", cwd=MOBILE_DIR)

    print("Running flutter pub get...")
    run("flutter pub get", cwd=MOBILE_DIR)


def get_flutter_emulators():
    try:
        result = subprocess.check_output("flutter emulators", shell=True).decode()
        lines = result.splitlines()

        emulators = []

        for line in lines:
            if "•" in line:
                emulator_id = line.split("•")[0].strip()
                if emulator_id:
                    emulators.append(emulator_id)

        return emulators

    except Exception:
        return []


def launch_emulator_optional():
    print("Launch Android emulator? (y/n): ", end="")
    choice = input().strip().lower()

    if choice not in ["y", "yes"]:
        print("Skipping emulator launch.")
        return

    print("Checking available emulators...")

    emulators = get_flutter_emulators()

    if not emulators:
        print("No emulators found.")
        return

    emulator_id = emulators[0]

    print(f"Launching emulator: {emulator_id}")

    try:
        subprocess.Popen(
            f"flutter emulators --launch {emulator_id}",
            shell=True,
            cwd=MOBILE_DIR
        )
    except Exception as e:
        print("Failed to launch emulator:", e)


def open_terminal(command, cwd):
    if IS_WINDOWS:
        subprocess.Popen(
            f'start cmd /k "cd /d {cwd} && {command}"',
            shell=True
        )
    else:
        terminals = [
            "gnome-terminal",
            "konsole",
            "xfce4-terminal",
            "x-terminal-emulator",
            "xterm"
        ]

        for term in terminals:
            if command_exists(term):
                subprocess.Popen(
                    [term, "-e", f"bash -c 'cd {cwd} && {command}; exec bash'"]
                )
                return

        print("No terminal emulator found.")


def start_backend():
    print("Starting backend...")

    if IS_WINDOWS:
        env_cmd = f"set OPENROUTER_API_KEY={OPENROUTER_KEY} && python main.py"
    else:
        env_cmd = f"export OPENROUTER_API_KEY={OPENROUTER_KEY} && python main.py"

    open_terminal(env_cmd, API_DIR)


def start_localtunnel():
    print("Starting LocalTunnel...")

    if not command_exists("lt"):
        print("LocalTunnel not found. Installing...")

        if not command_exists("npm"):
            print("npm is not installed. Please install Node.js.")
            sys.exit(1)

        run("npm install -g localtunnel")

    open_terminal("lt --port 5000 --subdomain anxease", ROOT)


def start_flutter():
    print("Starting Flutter app...")
    open_terminal("flutter run", MOBILE_DIR)


def main():
    try:
        print("===================================")
        print("Starting Anxease Development Setup")
        print("===================================")

        ensure_python_deps()
        ensure_flutter()

        launch_emulator_optional()

        start_backend()
        start_localtunnel()
        start_flutter()

        print("Anxease started successfully.")

    except Exception as e:
        print("Unexpected error:")
        print(e)


if __name__ == "__main__":
    main()