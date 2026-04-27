from __future__ import annotations

from fastapi import HTTPException

from app.core.settings import settings
from app.schemas.vision import OCRResponse
from app.services.images import load_image


def extract_text(content: bytes) -> OCRResponse:
    try:
        import pytesseract
    except ImportError as exc:
        raise HTTPException(
            status_code=503,
            detail="pytesseract dependency is not installed on the ML service.",
        ) from exc

    if settings.tesseract_cmd:
        pytesseract.pytesseract.tesseract_cmd = settings.tesseract_cmd

    image = load_image(content)
    text = pytesseract.image_to_string(image).strip()
    return OCRResponse(text=text)
