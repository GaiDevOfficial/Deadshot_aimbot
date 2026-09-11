@echo off
:: Adminisztrátori jogosultság ellenőrzése
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Rendszergazdai jogosultsag szukseges! Ujrainditas Adminisztratorkent...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

title Célrendszer Környezet Beállítása
color 0A
echo ===================================================
echo [1/5] Python es fuggosegek ellenorzese...
echo ===================================================

python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Python nem talalhato! Telepites inditasa...
    curl -o python_installer.exe https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
    echo [*] Python telepitese C++ futtatokornyezettel együtt...
    python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del python_installer.exe
    set "PATH=%ProgramFiles%\Python311;%ProgramFiles%\Python311\Scripts;%PATH%"
) else (
    echo [+] Python mar telepitve van.
)

echo.
echo ===================================================
echo [2/5] Virtualis kornyezet (venv) letrehozasa...
echo ===================================================

if not exist "venv" (
    python -m venv venv
    echo [+] Virtualis kornyezet sikeresen letrehozva.
) else (
    echo [+] 'venv' mappa mar létezik.
)

echo.
echo ===================================================
echo [3/5] Fuggosegek telepitese...
echo ===================================================

call venv\Scripts\activate.bat

python -m pip install --upgrade pip
pip install numpy opencv-python mss pywin32 PyQt6 ultralytics onnxruntime

echo.
echo ===================================================
echo [4/5] ONNX Modell ellenorzes...
echo ===================================================

if not exist "yolov8n.onnx" (
    if exist "yolov8n.pt" (
        echo [*] yolov8n.pt konvertalasa ONNX formatumba...
        python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx', dynamic=False, simplify=True)"
    ) else (
        echo [!] HIBA: Sem yolov8n.onnx, sem yolov8n.pt nem talalhato ebben a mappaban!
        pause
        exit /b
    )
) else (
    echo [+] ONNX modell rendben.
)

echo.
echo ===================================================
echo [5/5] Program inditasa...
echo ===================================================

if exist "AIMBOT.py" (
    python AIMBOT.py
) else (
    echo [!] AIMBOT.py nem talalhato!
    pause
)

pause