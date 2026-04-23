from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ML Service", version="1.0.0")

# Разрешаем запросы с Flutter приложения
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "ok", "service": "ml-service"}

@app.get("/")
async def root():
    return {"message": "ML Service is running"}

# Если нужны эндпоинты для вашего MLGatewayService
@app.post("/vision/face/detect")
async def detect_faces():
    return {"status": "not implemented yet"}

@app.post("/vision/text/ocr")
async def recognize_text():
    return {"status": "not implemented yet"}

@app.post("/audio/speech/transcribe")
async def transcribe_speech():
    return {"status": "not implemented yet"}