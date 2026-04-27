from fastapi import HTTPException, UploadFile


async def read_upload_bytes(file: UploadFile) -> bytes:
    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")
    return content
