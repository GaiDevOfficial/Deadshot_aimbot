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
    echo [*] Python telepitese...
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
echo [4/5] YOLO Modell automatikus letoltese es konvertalasa...
echo ===================================================

if not exist "yolov8n.onnx" (
    echo [*] Model nem talalhato, Letoltes es ONNX konvertalas folyamatban...
    python -c "from ultralytics import YOLO; model = YOLO('yolov8n.pt'); model.export(format='onnx', dynamic=False, simplify=True)"
    
    :: Töröljük a nyers .pt fájlt, hogy ne foglaljon felesleges helyet
    if exist "yolov8n.pt" del yolov8n.pt
    echo [+] YOLOv8 ONNX modell sikeresen elokeszitve!
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
    echo [!] HIBA: Az AIMBOT.py fájlnak a .bat mellett kell lennie!
    pause
)

pause