@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo ComfyUI Installation Script
echo ==========================================
echo.

:: Jump to main execution
goto main

:: Function to install Python 3.12 using winget
:install_python312
echo Installing Python 3.12 using winget...
winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo ERROR: Failed to install Python 3.12 using winget
    echo Please manually install Python 3.12 and add it to your PATH
    pause
    exit /b 1
)
echo Python 3.12 installation completed.
echo Refreshing PATH and trying again...
:: Refresh PATH environment variable
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYSTEM_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
set "PATH=%SYSTEM_PATH%;%USER_PATH%"
goto :eof

:: Function to create venv with Python 3.12
:create_venv_312
echo Attempting to create virtual environment with Python 3.12...

:: Try different ways to find Python 3.12
python3.12 -m venv venv 2>nul && (
    echo Virtual environment created successfully with python3.12.
    goto :eof
)

py -3.12 -m venv venv 2>nul && (
    echo Virtual environment created successfully with py -3.12.
    goto :eof
)

:: Check if default python is 3.12
python --version 2>nul | findstr "3.12" >nul && (
    python -m venv venv
    if not errorlevel 1 (
        echo Virtual environment created successfully with default python 3.12.
        goto :eof
    )
)

:: Try to find Python 3.12 in common installation paths
set "PYTHON312_PATHS=%LOCALAPPDATA%\Programs\Python\Python312\python.exe;%PROGRAMFILES%\Python312\python.exe;%PROGRAMFILES(X86)%\Python312\python.exe"

for %%p in (%PYTHON312_PATHS%) do (
    if exist "%%p" (
        echo Found Python 3.12 at: %%p
        "%%p" -m venv venv
        if not errorlevel 1 (
            echo Virtual environment created successfully.
            goto :eof
        )
    )
)

echo Python 3.12 not found or unable to create venv. Installing Python 3.12...
call :install_python312

:: Try once more after installation with refreshed environment
echo Retrying virtual environment creation after Python installation...
echo Attempting with refreshed PATH...

:: Try py launcher again (most likely to work after winget install)
py -3.12 -m venv venv 2>nul && (
    echo Virtual environment created successfully with py -3.12 after installation.
    goto :eof
)

:: Try to find newly installed Python in winget's typical location
if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\python3.12.exe" (
    echo Found winget-installed Python 3.12 in WindowsApps
    "%LOCALAPPDATA%\Microsoft\WindowsApps\python3.12.exe" -m venv venv
    if not errorlevel 1 (
        echo Virtual environment created successfully with WindowsApps Python.
        goto :eof
    )
)

:: Final attempt with more potential paths
set "WINGET_PATHS=%LOCALAPPDATA%\Microsoft\WindowsApps\python.exe;%PROGRAMFILES%\WindowsApps\PythonSoftwareFoundation.Python.3.12*\python.exe"
for %%p in (%WINGET_PATHS%) do (
    if exist "%%p" (
        "%%p" --version 2>nul | findstr "3.12" >nul && (
            echo Found Python 3.12 at: %%p
            "%%p" -m venv venv
            if not errorlevel 1 (
                echo Virtual environment created successfully.
                goto :eof
            )
        )
    )
)

:: If still failing, there's a deeper issue
echo ERROR: Unable to create Python 3.12 virtual environment even after installation.
echo Please ensure Python 3.12 is properly installed and accessible.
echo You may need to restart your command prompt or computer.
pause
exit /b 1

:: Function to check Python version in venv
:check_venv_python
call venv\Scripts\activate.bat >nul 2>&1
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if "%MAJOR%.%MINOR%" == "3.12" (
    set PYTHON_OK=1
) else (
    set PYTHON_OK=0
)
goto :eof

:main
echo ==========================================
echo Checking Python 3.12 setup...
echo ==========================================

:: Scenario 1: venv folder does not exist
if not exist "venv\Scripts\activate.bat" (
    echo Virtual environment not found. Creating new venv with Python 3.12...
    call :create_venv_312
    if exist "venv\Scripts\activate.bat" (
        echo Activating virtual environment...
        call venv\Scripts\activate.bat
        goto continue_install
    ) else (
        echo ERROR: Failed to create virtual environment
        pause
        exit /b 1
    )
)

:: Scenario 2 & 3: venv folder exists - check Python version
echo Virtual environment found. Checking Python version...
call :check_venv_python

if %PYTHON_OK% == 1 (
    echo Virtual environment is using Python 3.12. Continuing...
    call venv\Scripts\activate.bat
    goto continue_install
) else (
    echo Virtual environment is using Python %PYTHON_VERSION% (not 3.12^)
    echo Deleting existing virtual environment...
    rmdir /s /q venv
    echo Creating new virtual environment with Python 3.12...
    call :create_venv_312
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

:continue_install
echo.
echo Virtual environment activated with Python 3.12.
for /f "tokens=2" %%i in ('python --version 2^>^&1') do echo Current Python version: %%i
echo.

:: Upgrade pip
echo ==========================================
echo Upgrading pip to latest version...
echo ==========================================
python -m pip install --upgrade pip
if errorlevel 1 (
    echo ERROR: Failed to upgrade pip
    pause
    exit /b 1
)
echo Pip upgraded successfully.
echo.

:: Install requirements first (with error handling for build issues)
echo ==========================================
echo Installing requirements from requirements.txt...
echo ==========================================
if not exist "requirements.txt" (
    echo ERROR: requirements.txt file not found
    pause
    exit /b 1
)

echo Installing requirements with build error tolerance...
pip install -r requirements.txt --prefer-binary
echo Requirements installation completed (ignoring any errors).
echo.

:: Install PyTorch with CUDA support
echo ==========================================
echo Installing PyTorch with CUDA support...
echo ==========================================
echo Trying stable PyTorch with CUDA 12.1 first (more reliable)...
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
if errorlevel 1 (
    echo Stable PyTorch failed, trying nightly with CUDA 12.4...
    pip3 install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu124
    if errorlevel 1 (
        echo ERROR: Failed to install PyTorch (both stable and nightly)
        pause
        exit /b 1
    ) else (
        echo PyTorch nightly installed successfully.
        echo Installing compatible torchvision and torchaudio...
        pip3 install --pre torchvision --index-url https://download.pytorch.org/whl/nightly/cu124 --force-reinstall --no-deps
        pip3 install --pre torchaudio --index-url https://download.pytorch.org/whl/nightly/cu124 --force-reinstall --no-deps
        echo Nightly PyTorch installation completed.
    )
) else (
    echo Stable PyTorch with CUDA 12.1 installed successfully.
)
echo.

:: Install critical packages that may have failed
echo ==========================================
echo Installing critical packages individually...
echo ==========================================
echo Installing PyYAML (required for ComfyUI)...
pip install pyyaml
echo.
echo Installing other essential packages...
pip install pillow numpy scipy tqdm psutil aiohttp safetensors transformers tokenizers einops torchsde
echo.
echo Attempting to install sentencepiece with alternative methods...
pip install sentencepiece --no-build-isolation 2>nul || (
    echo Sentencepiece build failed, trying to install without it...
    echo Sentencepiece is optional for many workflows
)
echo.

echo.
echo ==========================================
echo Installation completed successfully!
echo ==========================================
echo.
echo To run ComfyUI:
echo 1. Activate the virtual environment: venv\Scripts\activate.bat
echo 2. Run: python main.py
echo.
echo Virtual environment is currently active.
echo You can now run: python main.py
echo.
pause