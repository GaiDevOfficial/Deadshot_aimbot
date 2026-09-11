@echo off
:: Munkamappa rögzítése a szkript helyére
cd /d "%~dp0"

title Kornyezet Beallitasa es Inditas
color 0A

echo ===================================================
echo [1/4] Python es csomagkezelo ellenorzese...
echo ===================================================

:: 1. Python elérhetőségének ellenőrzése
where python >nul 2>&1
if %errorLevel% neq 0 (
    if exist "%ProgramFiles%\Python311\python.exe" (
        set "PYTHON_CMD=%ProgramFiles%\Python311\python.exe"
    ) else (
        echo [!] A Python nincs telepitve a rendszeren.
        echo [*] Kerlek telepitsd a Pythont a python.org oldalrol (pip es PATH opcioval)!
        pause
        exit /b
    )
) else (
    set "PYTHON_CMD=python"
)

echo [+] Hasznalt Python: %PYTHON_CMD%

echo.
echo ===================================================
echo [2/4] Virtualis kornyezet es csomagok frissitese...
echo ===================================================

:: Virtuális környezet létrehozása, ha nem létezik
if not exist "venv" (
    echo [*] Virtualis kornyezet (venv) letrehozasa...
    "%PYTHON_CMD%" -m venv venv
)

:: Belépés a virtuális környezetbe
call venv\Scripts\activate.bat

echo.
echo ===================================================
echo [3/4] Dependenciak telepitese...
echo ===================================================

:: Csomagok kényszerített telepítése a venv-en belül
python -m pip install --upgrade pip --no-warn-script-location
python -m pip install --no-cache-dir numpy opencv-python mss pywin32 PyQt6 ultralytics onnxruntime

echo.
echo ===================================================
echo [4/4] Alkalmazas inditasa...
echo ===================================================

if exist "%~dp0AIMBOT.py" (
    echo [+] AIMBOT.py inditasa...
    python "%~dp0AIMBOT.py"
) else (
    echo [!] HIBA: Az AIMBOT.py nem található ebben a mappában:
    echo %~dp0
    pause
)

pause