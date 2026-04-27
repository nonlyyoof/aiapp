from __future__ import annotations

from dataclasses import dataclass

from fastapi import HTTPException

from app.core.settings import settings
from app.schemas.vision import FaceBox
from app.services.images import load_image

try:
    import face_recognition
except ImportError:  # pragma: no cover
    face_recognition = None


@dataclass(frozen=True)
class FaceEmbeddingResult:
    embedding: list[float]
    selected_box: FaceBox
    faces_detected: int
    provider: str


def _to_rgb_array(content: bytes):
    image = load_image(content)
    try:
        import numpy as np
    except ImportError as exc:
        raise HTTPException(
            status_code=503,
            detail="NumPy dependency is not installed on the ML service.",
        ) from exc
    return np.array(image)


def _require_face_recognition() -> None:
    if face_recognition is None:
        raise HTTPException(
            status_code=503,
            detail=(
                "face-recognition dependency is not installed on the ML service. "
                "Install it to enable embeddings and face verification."
            ),
        )


def _location_to_box(location: tuple[int, int, int, int]) -> FaceBox:
    top, right, bottom, left = location
    return FaceBox(
        x=int(left),
        y=int(top),
        width=int(right - left),
        height=int(bottom - top),
    )


def _largest_face(locations: list[tuple[int, int, int, int]]) -> tuple[int, int, int, int]:
    return max(locations, key=lambda loc: (loc[2] - loc[0]) * (loc[1] - loc[3]))


def detect_faces_with_embeddings(content: bytes) -> list[FaceBox]:
    _require_face_recognition()
    rgb_array = _to_rgb_array(content)
    locations = face_recognition.face_locations(
        rgb_array,
        model=settings.face_detection_model,
    )
    return [_location_to_box(location) for location in locations]


def extract_face_embedding(content: bytes) -> FaceEmbeddingResult:
    _require_face_recognition()
    rgb_array = _to_rgb_array(content)
    locations = face_recognition.face_locations(
        rgb_array,
        model=settings.face_detection_model,
    )

    if not locations:
        raise HTTPException(status_code=400, detail="No face detected in the image.")

    selected_location = _largest_face(locations)
    encodings = face_recognition.face_encodings(
        rgb_array,
        known_face_locations=[selected_location],
    )

    if not encodings:
        raise HTTPException(status_code=400, detail="Failed to extract face embedding.")

    return FaceEmbeddingResult(
        embedding=encodings[0].tolist(),
        selected_box=_location_to_box(selected_location),
        faces_detected=len(locations),
        provider="face_recognition",
    )


def verify_face_pair(reference_content: bytes, candidate_content: bytes) -> tuple[bool, float]:
    _require_face_recognition()

    reference_result = extract_face_embedding(reference_content)
    candidate_result = extract_face_embedding(candidate_content)

    distance = face_recognition.face_distance(
        [reference_result.embedding],
        candidate_result.embedding,
    )[0]
    distance = float(distance)
    return distance <= settings.face_match_threshold, distance
