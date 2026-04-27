from fastapi import APIRouter, File, UploadFile

from app.schemas.audio import SpeechToTextResponse
from app.services.speech_service import transcribe_audio
from app.services.uploads import read_upload_bytes

router = APIRouter()


@router.post("/speech/transcribe", response_model=SpeechToTextResponse)
async def transcribe_route(file: UploadFile = File(...)) -> SpeechToTextResponse:
    content = await read_upload_bytes(file)
    return transcribe_audio(content, file.filename)
