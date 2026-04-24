import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import io
import pytesseract
import platform

# Настройка Tesseract (Windows)
if platform.system() == "Windows":
    pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

app = FastAPI(title="ML Service", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def decode_image(file_bytes: bytes):
    image = Image.open(io.BytesIO(file_bytes))
    return cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

@app.get("/health")
async def health():
    return {"status": "ok", "service": "ml-service"}

# ============ FACE DETECTION (простая заглушка) ============
@app.post("/vision/face/detect")
async def detect_faces(file: UploadFile = File(...)):
    """Упрощенное распознавание лиц через Haar Cascade"""
    try:
        contents = await file.read()
        image = decode_image(contents)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Используем встроенный классификатор OpenCV
        face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        )
        
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        faces_list = []
        for i, (x, y, w, h) in enumerate(faces):
            faces_list.append({
                "id": i,
                "bbox": {"x": int(x), "y": int(y), "width": int(w), "height": int(h)},
                "confidence": 0.8
            })
        
        return {
            "success": True,
            "face_count": len(faces_list),
            "faces": faces_list
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

# ============ OCR ============
@app.post("/vision/text/ocr")
async def recognize_text(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        text = pytesseract.image_to_string(image, lang="rus+eng")
        
        return {
            "success": True,
            "text": text.strip(),
            "word_count": len(text.strip().split()) if text.strip() else 0
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

# ============ ОБЪЕДИНЕННЫЙ АНАЛИЗ ============
@app.post("/vision/analyze")
async def analyze_image(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = decode_image(contents)
        
        # Face detection
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        )
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        # OCR
        pil_image = Image.open(io.BytesIO(contents))
        text = pytesseract.image_to_string(pil_image, lang="rus+eng")
        
        return {
            "success": True,
            "face_count": len(faces),
            "faces": [{"x": int(x), "y": int(y), "width": int(w), "height": int(h)} 
                      for (x, y, w, h) in faces],
            "text": text.strip() if text.strip() else None
        }
        
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)