import sys
import os
import traceback
import numpy as np
import win32api, win32con, win32gui
from mss import mss
from ultralytics import YOLO
from PyQt6.QtWidgets import QApplication, QWidget
from PyQt6.QtGui import QPainter, QColor, QPen
from PyQt6.QtCore import Qt, QTimer

LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(sys.argv[0])), "error_log.txt")

def log_exception(exc_type, exc_value, exc_traceback):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write("=== HIBÁVAL ÁLLT LE A PROGRAM ===\n")
        traceback.print_exception(exc_type, exc_value, exc_traceback, file=f)
        f.write("\n")

sys.excepthook = log_exception

def get_resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, relative_path)
    return os.path.join(os.path.abspath("."), relative_path)

FOV_SIZE = 400          
CONFIDENCE = 0.40       
IOU_THRESHOLD = 0.50    
BASE_SENS = 0.32        
DEADZONE = 1.5          

SCREEN_WIDTH = win32api.GetSystemMetrics(0)
SCREEN_HEIGHT = win32api.GetSystemMetrics(1)
CENTER_X = SCREEN_WIDTH // 2
CENTER_Y = SCREEN_HEIGHT // 2

monitor = {
    "top": CENTER_Y - (FOV_SIZE // 2),
    "left": CENTER_X - (FOV_SIZE // 2),
    "width": FOV_SIZE,
    "height": FOV_SIZE
}

# ONNX Modell betöltése
model_path = get_resource_path("yolov8n.onnx")
if not os.path.exists(model_path):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"HIBA: A yolov8n.onnx fájl nem található: {model_path}\n")

model = YOLO(model_path, task="detect")

def move_mouse_precise(dx, dy):
    win32api.mouse_event(win32con.MOUSEEVENTF_MOVE, int(round(dx)), int(round(dy)), 0, 0)

class OverlayWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setGeometry(CENTER_X - (FOV_SIZE // 2), CENTER_Y - (FOV_SIZE // 2), FOV_SIZE, FOV_SIZE)
        
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint | 
            Qt.WindowType.WindowStaysOnTopHint | 
            Qt.WindowType.Tool
        )
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents)

        self.boxes = []
        self.head_point = None

        self.timer = QTimer()
        self.timer.timeout.connect(self.process_ai)
        self.timer.start(8)

    def showEvent(self, event):
        super().showEvent(event)
        hwnd = self.winId()
        extended_style = win32gui.GetWindowLong(hwnd, win32con.GWL_EXSTYLE)
        win32gui.SetWindowLong(hwnd, win32con.GWL_EXSTYLE, extended_style | win32con.WS_EX_TRANSPARENT | win32con.WS_EX_LAYERED)

    def process_ai(self):
        try:
            with mss() as ssc:
                screenshot = np.array(ssc.grab(monitor))
                frame = screenshot[:, :, :3]

            results = model.predict(frame, classes=[0], conf=CONFIDENCE, iou=IOU_THRESHOLD, verbose=False)

            self.boxes = []
            self.head_point = None
            best_target = None
            min_dist = float('inf')
            fov_center = FOV_SIZE / 2

            for result in results:
                boxes = result.boxes.xyxy
                if hasattr(boxes, 'cpu'):
                    boxes = boxes.cpu().numpy()

                for box in boxes:
                    x1 = int(np.clip(box[0], 0, FOV_SIZE))
                    y1 = int(np.clip(box[1], 0, FOV_SIZE))
                    x2 = int(np.clip(box[2], 0, FOV_SIZE))
                    y2 = int(np.clip(box[3], 0, FOV_SIZE))
                    
                    box_width = x2 - x1
                    box_height = y2 - y1

                    if box_width < 8 or box_height < 12:
                        continue

                    self.boxes.append((x1, y1, box_width, box_height))
                    
                    head_x = x1 + (box_width / 2.0)
                    head_y = y1 + (box_height * 0.13)

                    dist = np.hypot(head_x - fov_center, head_y - fov_center)

                    if dist < min_dist:
                        min_dist = dist
                        best_target = (head_x - fov_center, head_y - fov_center)
                        self.head_point = (int(head_x), int(head_y))

            left_click = win32api.GetAsyncKeyState(0x01) < 0
            right_click = win32api.GetAsyncKeyState(0x02) < 0

            if best_target and (left_click or right_click):
                dx, dy = best_target
                
                if abs(dx) > DEADZONE or abs(dy) > DEADZONE:
                    smooth_factor = BASE_SENS * (1.0 - np.exp(-min_dist / 80.0))
                    smooth_factor = max(smooth_factor, 0.08)
                    
                    move_mouse_precise(dx * smooth_factor, dy * smooth_factor)

            self.update()
        except Exception as e:
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(f"Hiba a process_ai ciklusban: {e}\n")

    def paintEvent(self, event):
        painter = QPainter(self)
        
        pen_box = QPen(QColor(0, 255, 0), 2)
        painter.setPen(pen_box)
        for x, y, w, h in self.boxes:
            painter.drawRect(x, y, w, h)

        if self.head_point:
            pen_head = QPen(QColor(255, 0, 0), 6)
            painter.setPen(pen_head)
            painter.drawPoint(self.head_point[0], self.head_point[1])

if __name__ == "__main__":
    app = QApplication(sys.argv)
    overlay = OverlayWindow()
    overlay.show()
    sys.exit(app.exec())