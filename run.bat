@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo ComfyUI Launcher
echo ==========================================
echo.

:: Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo.
    echo Please run install.bat first to set up the environment.
    echo.
    pause
    exit /b 1
)

echo Virtual environment found. Activating...
call venv\Scripts\activate.bat

:: Give a moment for activation to complete
timeout /t 2 /nobreak >nul

echo.
echo Virtual environment activated.
echo Starting ComfyUI...
echo.
echo ==========================================
echo ComfyUI is starting...
echo ==========================================
echo.

:: Run ComfyUI
python main.py

:: Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo ==========================================
    echo ComfyUI exited with an error.
    echo ==========================================
    pause
) else (
    echo.
    echo ==========================================
    echo ComfyUI has stopped.
    echo ==========================================
)

pause