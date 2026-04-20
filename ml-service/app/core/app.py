from fastapi import FastAPI

from app.api.router import api_router
from app.core.settings import settings


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.service_name,
        version=settings.service_version,
        description="Python ML service for face detection, OCR and speech recognition.",
    )
    app.include_router(api_router)
    return app
