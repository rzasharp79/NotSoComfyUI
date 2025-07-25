@echo off
echo ==========================================
echo Fixing PyTorch Installation
echo ==========================================
echo.

call venv\Scripts\activate.bat

echo Uninstalling current PyTorch...
pip uninstall torch torchvision torchaudio -y

echo.
echo Installing stable PyTorch with CUDA 12.1...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

if errorlevel 1 (
    echo ERROR: Failed to install stable PyTorch
    pause
    exit /b 1
)

echo.
echo PyTorch installation fixed successfully!
echo Testing PyTorch CUDA availability...
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA device count: {torch.cuda.device_count()}'); print(f'Current device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"

echo.
echo You can now run ComfyUI with run.bat
pause