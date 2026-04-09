@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Absolute path to this setup.bat directory (%~dp0 always has trailing backslash)
set "PROJECT_DIR=%~dp0"

REM Trim trailing backslash for cleaner output
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "VENV_DIR=%PROJECT_DIR%\env"
set "REQ_FILE=%PROJECT_DIR%\requirements.txt"
set "PYTHON_EXE="

echo ==================================================
echo Project setup started
echo Project directory: "%PROJECT_DIR%"
echo Virtual env path:  "%VENV_DIR%"
echo ==================================================

REM -----------------------------------------------------------------------------
REM Find a usable Python launcher/executable
REM -----------------------------------------------------------------------------
where py >nul 2>&1
if %ERRORLEVEL%==0 (
    set "PYTHON_EXE=py -3"
) else (
    where python >nul 2>&1
    if %ERRORLEVEL%==0 (
        set "PYTHON_EXE=python"
    ) else (
        echo [ERROR] Python was not found on PATH.
        echo Install Python 3.9+ and ensure "py" or "python" is available.
        exit /b 1
    )
)

REM -----------------------------------------------------------------------------
REM Create virtual environment if it does not exist
REM -----------------------------------------------------------------------------
if exist "%VENV_DIR%\Scripts\python.exe" (
    echo [INFO] Existing virtual environment detected. Reusing: "%VENV_DIR%"
) else (
    echo [INFO] Creating virtual environment...
    %PYTHON_EXE% -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment at "%VENV_DIR%".
        exit /b 1
    )
)

REM -----------------------------------------------------------------------------
REM Upgrade pip/setuptools/wheel inside the venv
REM -----------------------------------------------------------------------------
echo [INFO] Upgrading pip, setuptools, wheel...
call "%VENV_DIR%\Scripts\python.exe" -m pip install --upgrade pip setuptools wheel
if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip tooling.
    exit /b 1
)

REM -----------------------------------------------------------------------------
REM Install dependencies if requirements.txt exists
REM -----------------------------------------------------------------------------
if exist "%REQ_FILE%" (
    echo [INFO] Installing dependencies from requirements.txt...
    call "%VENV_DIR%\Scripts\python.exe" -m pip install -r "%REQ_FILE%"
    if errorlevel 1 (
        echo [ERROR] Dependency installation failed.
        exit /b 1
    )
) else (
    echo [WARN] No requirements.txt found at "%REQ_FILE%". Skipping dependency install.
)

REM -----------------------------------------------------------------------------
REM Smoke check
REM -----------------------------------------------------------------------------
echo [INFO] Verifying Python in virtual environment...
call "%VENV_DIR%\Scripts\python.exe" --version
if errorlevel 1 (
    echo [ERROR] Virtual environment verification failed.
    exit /b 1
)

echo.
echo [SUCCESS] Setup complete.
echo To activate the virtual environment, run:
echo   call "%VENV_DIR%\Scripts\activate.bat"
echo.

exit /b 0