from __future__ import annotations

import io
from typing import Any

from fastapi import HTTPException

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    Image = None


def require_dependency(dependency: Any, feature: str) -> None:
    if dependency is None:
        raise HTTPException(
            status_code=503,
            detail=f"{feature} dependency is not installed on the ML service.",
        )


def load_image(content: bytes):
    require_dependency(Image, "Pillow")
    try:
        return Image.open(io.BytesIO(content)).convert("RGB")
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=400, detail="Invalid image file.") from exc
