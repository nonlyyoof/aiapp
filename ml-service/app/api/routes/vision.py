from fastapi import APIRouter, File, UploadFile

from app.schemas.vision import FaceDetectionResponse, FaceEmbeddingResponse, FaceVerificationResponse, OCRResponse
from app.services.face_service import detect_faces, embed_face, verify_faces
from app.services.ocr_service import extract_text
from app.services.uploads import read_upload_bytes

router = APIRouter()


@router.post("/face/detect", response_model=FaceDetectionResponse)
async def detect_faces_route(file: UploadFile = File(...)) -> FaceDetectionResponse:
    content = await read_upload_bytes(file)
    return detect_faces(content)


@router.post("/face/embed", response_model=FaceEmbeddingResponse)
async def embed_face_route(file: UploadFile = File(...)) -> FaceEmbeddingResponse:
    content = await read_upload_bytes(file)
    return embed_face(content)


@router.post("/face/verify", response_model=FaceVerificationResponse)
async def verify_faces_route(
    reference_file: UploadFile = File(...),
    candidate_file: UploadFile = File(...),
) -> FaceVerificationResponse:
    reference_content = await read_upload_bytes(reference_file)
    candidate_content = await read_upload_bytes(candidate_file)
    return verify_faces(reference_content, candidate_content)


@router.post("/text/ocr", response_model=OCRResponse)
async def ocr_route(file: UploadFile = File(...)) -> OCRResponse:
    content = await read_upload_bytes(file)
    return extract_text(content)
