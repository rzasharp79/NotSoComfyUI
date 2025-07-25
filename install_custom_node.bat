@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo ComfyUI Custom Node Installer
echo ==========================================
echo.

:: Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo Please run install.bat first to set up the environment.
    echo.
    pause
    exit /b 1
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

:: Give a moment for activation to complete
timeout /t 1 /nobreak >nul

echo Virtual environment activated.
echo.

:get_git_url
:: Ask user for git repository URL
echo ==========================================
echo Enter Git Repository Information
echo ==========================================
echo.
echo Please paste the git repository URL for the custom node:
echo Example: https://github.com/Comfy-Org/ComfyUI-Manager.git
echo.
set /p GIT_URL="Git URL: "

:: Validate input
if "%GIT_URL%"=="" (
    echo ERROR: No URL provided. Please try again.
    echo.
    goto get_git_url
)

:: Extract repository name from URL
for %%f in ("%GIT_URL%") do set "REPO_NAME=%%~nf"
set "REPO_NAME=%REPO_NAME:.git=%"

echo.
echo Repository: %REPO_NAME%
echo URL: %GIT_URL%
echo.

:: Confirm with user
set /p CONFIRM="Proceed with installation? (y/n): "
if /i not "%CONFIRM%"=="y" (
    echo Installation cancelled.
    goto get_git_url
)

echo.
echo ==========================================
echo Installing Custom Node: %REPO_NAME%
echo ==========================================
echo.

:: Check if custom_nodes directory exists
if not exist "custom_nodes" (
    echo Creating custom_nodes directory...
    mkdir custom_nodes
)

:: Navigate to custom_nodes directory
cd custom_nodes

:: Check if repository already exists
if exist "%REPO_NAME%" (
    echo WARNING: Directory %REPO_NAME% already exists!
    set /p OVERWRITE="Do you want to delete and reinstall? (y/n): "
    if /i "%OVERWRITE%"=="y" (
        echo Removing existing directory...
        rmdir /s /q "%REPO_NAME%"
    ) else (
        echo Installation cancelled.
        cd ..
        goto prompt_again
    )
)

:: Clone the repository
echo Cloning repository...
git clone "%GIT_URL%"

if errorlevel 1 (
    echo ERROR: Failed to clone repository.
    echo Please check the URL and try again.
    cd ..
    goto prompt_again
)

echo Repository cloned successfully.
echo.

:: Navigate to the cloned directory
if not exist "%REPO_NAME%" (
    echo ERROR: Cloned directory not found. Something went wrong.
    cd ..
    goto prompt_again
)

cd "%REPO_NAME%"
echo Navigated to: %cd%
echo.

:: Check for requirements.txt
if exist "requirements.txt" (
    echo Found requirements.txt file.
    echo Installing dependencies...
    echo.
    pip install -r requirements.txt
    
    if errorlevel 1 (
        echo.
        echo WARNING: Some dependencies may have failed to install.
        echo The custom node may still work, but check for any error messages above.
    ) else (
        echo.
        echo Dependencies installed successfully.
    )
) else (
    echo No requirements.txt file found.
    echo No additional dependencies to install.
)

echo.
echo ==========================================
echo Custom Node Installation Complete!
echo ==========================================
echo.
echo Custom node '%REPO_NAME%' has been installed in:
echo %cd%
echo.
echo To use the custom node:
echo 1. Restart ComfyUI (if it's currently running)
echo 2. The new nodes should appear in the ComfyUI interface
echo.

:: Return to root directory
cd ..\..

:prompt_again
echo.
echo ==========================================
set /p INSTALL_ANOTHER="Would you like to install another custom node? (y/n): "
if /i "%INSTALL_ANOTHER%"=="y" (
    echo.
    goto get_git_url
)

echo.
echo Exiting custom node installer.
echo The terminal will remain open for any additional commands.
echo.