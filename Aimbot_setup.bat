@echo off
:: Mappa rögzítése a tényleges könyvtárra (admin módban is)
cd /d "%~dp0"

:: Adminisztrátori jogosultság ellenőrzése és lekérése
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Rendszergazdai jogosultsag szukseges! Ujrainditas...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

title Célrendszer Teljes Környezet Beállítása
color 0A

echo ===================================================
echo [1/5] Python telepitese es ellenorzese...
echo ===================================================

:: Ellenőrizzük, hogy elérhető-e a Python
where python >nul 2>&1
if %errorLevel% neq 0 (
    if not exist "%ProgramFiles%\Python311\python.exe" (
        echo [*] Python nem talalhato. Letoltes folyamatban...
        curl -L -o python_installer.exe https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
        
        echo [*] Python csendes telepitese (PATH hozzaadasaval)...
        python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 SimpleInstall=1
        del python_installer.exe
    )
    :: PATH eroltetese az aktualis munkamenetben
    set "PATH=%ProgramFiles%\Python311;%ProgramFiles%\Python311\Scripts;%PATH%"
) else (
    echo [+] Python mar jelen van a rendszeren.
)

echo.
echo ===================================================
echo [2/5] Virtualis kornyezet (venv) letrehozasa...
echo ===================================================

if not exist "venv" (
    "%ProgramFiles%\Python311\python.exe" -m venv venv 2>nul || python -m venv venv
    echo [+] Virtualis kornyezet letrehozva.
) else (
    echo [+] 'venv' mappa rendben.
)

echo.
echo ===================================================
echo [3/5] Működési csomagok telepitese...
echo ===================================================

call venv\Scripts\activate.bat

python -m pip install --upgrade pip
pip install numpy opencv-python mss pywin32 PyQt6 ultralytics onnxruntime

echo.
echo ===================================================
echo [4/5] YOLO Modell letoltese es felkeszitese...
echo ===================================================

if not exist "yolov8n.onnx" (
    echo [*] Model konvertalasa ONNX formatumba...
    python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx', dynamic=False, simplify=True)"
    if exist "yolov8n.pt" del yolov8n.pt
    echo [+] ONNX modell letrehozva.
) else (
    echo [+] ONNX modell rendben.
)

echo.
echo ===================================================
echo [5/5] Inditas...
echo ===================================================

if exist "%~dp0AIMBOT.py" (
    python "%~dp0AIMBOT.py"
) else (
    echo [!] HIBA: Az AIMBOT.py nem talalhato ebben a mappaban: %~dp0
    pause
)

pause