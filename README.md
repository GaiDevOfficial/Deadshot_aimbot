# AI Vision Aim Assist & Overlay System

A high-performance, real-time computer vision aim assistance and visual overlay utility designed for FPS environments. Powered by **YOLOv8** object detection and **PyQt6** transparent window management, this software provides low-latency target acquisition and custom overlay feedback directly on top of your game window.

---

## Features

* **AI-Powered Detection:** Leverages Ultralytics YOLOv8 for accurate real-time player detection without relying on fixed color schemes or outlines.
* **Transparent DirectX/Game Overlay:** Utilizes PyQt6 and native Windows API (`WS_EX_TRANSPARENT`) for seamless, click-through visual feedback over Borderless Fullscreen applications.
* **Crowd & Close-Proximity Handling:** Customized Non-Maximum Suppression (NMS) parameters (`iou=0.65`) and coordinate clipping prevent tracking loss in tight, overlapping combat scenarios.
* **Smart Target Selection:** Dynamically locks onto the target head coordinate closest to the crosshair.
* **Adaptive Mouse Movement:** Features progressive smoothing multipliers and dynamic deadzones to prevent cursor jitter and overshoot.
* **Trigger Support:** Activates auto-tracking dynamically during left-click (firing) or right-click (aim-down-sights) inputs.

---

## Tech Stack

* **Language:** Python 3.10+
* **Core ML Framework:** Ultralytics YOLOv8 (PyTorch / ONNX Runtime)
* **GUI / Overlay:** PyQt6
* **Screen Capture:** `mss` (Fast multi-monitor capture)
* **Input & Window Management:** `pywin32` (Windows API hooks)
* **Computer Vision Processing:** OpenCV, NumPy

---

## Prerequisites

Before running or building the project, ensure you have the required runtime dependencies installed:

\`\`\`bash
pip install ultralytics PyQt6 opencv-python numpy mss pywin32
\`\`\`

> **Note:** For optimal performance on AMD GPUs (such as the RX 6600 series), it is recommended to run the model with DirectML execution providers:
> \`\`\`bash
> pip install onnxruntime-directml
> \`\`\`

---

## Installation & Setup

1. **Clone the Repository:**
   \`\`\`bash
   git clone https://github.com/your-username/ai-vision-aimbot.git
   cd ai-vision-aimbot
   \`\`\`

2. **Prepare the Model File:**
   Ensure `yolov8n.pt` (or your exported `.onnx` model) is placed directly in the project root directory.

3. **Run the Application:**
   \`\`\`bash
   python main.py
   \`\`\`

---

## Configuration

Key performance parameters can be adjusted directly at the top of `main.py`:

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `FOV_SIZE` | `int` | `700` | Detection field-of-view bounding region (in pixels). |
| `CONFIDENCE` | `float` | `0.35` | Minimum AI detection probability threshold. |
| `IOU_THRESHOLD` | `float` | `0.65` | NMS threshold for resolving overlapping/crowded targets. |
| `SENS_MULTIPLIER` | `float` | `0.28` | Mouse movement scaling factor (tune based on in-game sensitivity). |
| `DEADZONE` | `int` | `3` | Minimum pixel offset required before input triggers (prevents shake). |

---

## Building Executable (`.exe`)

To build a standalone Windows executable using PyInstaller:

1. **Install PyInstaller:**
   \`\`\`bash
   pip install pyinstaller
   \`\`\`

2. **Run Build Command:**
   \`\`\`bash
   pyinstaller --noconfirm --onedir --windowed --add-data "yolov8n.pt;." --collect-all ultralytics --collect-all PyQt6 main.py
   \`\`\`

3. **Output:**
   The compiled folder will be available inside the `dist/main/` directory. Run `main.exe` as Administrator for proper input privileges over game windows.

---

## Disclaimer & Fair Use Notice

This software is developed strictly for **educational, experimental, and research purposes** concerning computer vision, real-time object detection, and GUI overlays. 

* The use of automated assistance scripts in online competitive multiplayer games may violate the Terms of Service (ToS) of game developers and result in permanent account suspension.
* The developers assume no responsibility for any misuse, account penalties, or damages arising from the application of this code.
