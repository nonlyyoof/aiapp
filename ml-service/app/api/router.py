from fastapi import APIRouter

from app.api.routes import audio, health, vision

api_router = APIRouter()
api_router.include_router(health.router, tags=["health"])
api_router.include_router(vision.router, prefix="/vision", tags=["vision"])
api_router.include_router(audio.router, prefix="/audio", tags=["audio"])
