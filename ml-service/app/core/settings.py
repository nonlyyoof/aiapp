from __future__ import annotations

from dataclasses import dataclass
import os

from dotenv import load_dotenv


load_dotenv()


@dataclass(frozen=True)
class Settings:
    service_name: str = os.getenv("ML_SERVICE_NAME", "aiapp-ml-service")
    service_version: str = os.getenv("ML_SERVICE_VERSION", "0.1.0")
    host: str = os.getenv("ML_SERVICE_HOST", "0.0.0.0")
    port: int = int(os.getenv("ML_SERVICE_PORT", "8001"))
    whisper_model: str = os.getenv("WHISPER_MODEL", "base")
    tesseract_cmd: str = os.getenv("TESSERACT_CMD", "").strip()
    face_detection_model: str = os.getenv("FACE_DETECTION_MODEL", "hog")
    face_match_threshold: float = float(os.getenv("FACE_MATCH_THRESHOLD", "0.6"))


settings = Settings()
