from __future__ import annotations

import os
import tempfile

from fastapi import HTTPException

from app.core.settings import settings
from app.schemas.audio import SpeechToTextResponse


def transcribe_audio(content: bytes, filename: str | None) -> SpeechToTextResponse:
    try:
        import whisper
    except ImportError as exc:
        raise HTTPException(
            status_code=503,
            detail="openai-whisper dependency is not installed on the ML service.",
        ) from exc

    model = whisper.load_model(settings.whisper_model)

    suffix = os.path.splitext(filename or "audio.wav")[1] or ".wav"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
        temp_file.write(content)
        temp_path = temp_file.name

    try:
        result = model.transcribe(temp_path)
    finally:
        try:
            os.remove(temp_path)
        except OSError:
            pass

    return SpeechToTextResponse(
        text=result.get("text", "").strip(),
        language=result.get("language"),
    )
