from pydantic import BaseModel


class FaceBox(BaseModel):
    x: int
    y: int
    width: int
    height: int


class FaceDetectionResponse(BaseModel):
    facesDetected: int
    boxes: list[FaceBox]


class FaceEmbeddingResponse(BaseModel):
    facesDetected: int
    selectedBox: FaceBox | None = None
    embedding: list[float]
    provider: str


class FaceVerificationResponse(BaseModel):
    isMatch: bool
    distance: float
    threshold: float
    provider: str


class OCRResponse(BaseModel):
    text: str
