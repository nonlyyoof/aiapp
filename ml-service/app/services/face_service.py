from __future__ import annotations

from fastapi import HTTPException

from app.core.settings import settings
from app.schemas.vision import (
    FaceBox,
    FaceDetectionResponse,
    FaceEmbeddingResponse,
    FaceVerificationResponse,
)
from app.services.face_provider import (
    detect_faces_with_embeddings,
    extract_face_embedding,
    verify_face_pair,
)
from app.services.images import load_image


def detect_faces(content: bytes) -> FaceDetectionResponse:
    try:
        boxes = detect_faces_with_embeddings(content)
        return FaceDetectionResponse(facesDetected=len(boxes), boxes=boxes)
    except HTTPException as exc:
        if exc.status_code != 503:
            raise

    image = load_image(content)

    try:
        import cv2
        import numpy as np
    except ImportError as exc:
        raise HTTPException(
            status_code=503,
            detail="OpenCV dependency is not installed on the ML service.",
        ) from exc

    cascade_path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    classifier = cv2.CascadeClassifier(cascade_path)
    frame = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = classifier.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)

    boxes = [
        FaceBox(x=int(x), y=int(y), width=int(w), height=int(h))
        for x, y, w, h in faces
    ]
    return FaceDetectionResponse(facesDetected=len(boxes), boxes=boxes)


def embed_face(content: bytes) -> FaceEmbeddingResponse:
    result = extract_face_embedding(content)
    return FaceEmbeddingResponse(
        facesDetected=result.faces_detected,
        selectedBox=result.selected_box,
        embedding=result.embedding,
        provider=result.provider,
    )


def verify_faces(reference_content: bytes, candidate_content: bytes) -> FaceVerificationResponse:
    is_match, distance = verify_face_pair(reference_content, candidate_content)
    return FaceVerificationResponse(
        isMatch=is_match,
        distance=distance,
        threshold=settings.face_match_threshold,
        provider="face_recognition",
    )
