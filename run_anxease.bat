@echo off
title Anxease Launcher

cd /d %~dp0

echo Starting Anxease...

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python not installed.
    pause
    exit /b
)

python run_anxease.py

pause