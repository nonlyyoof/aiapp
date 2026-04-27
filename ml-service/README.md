# ML service

Python service for:

- face detection from an image
- face embeddings and face verification
- OCR from an image
- speech-to-text from an audio file

## Project layout

```text
ml-service/
  app/
    api/
    core/
    schemas/
    services/
    main.py
  tests/
  .env.example
  pyproject.toml
  requirements.txt
```

## First run

```powershell
.\scripts\bootstrap.ps1
.\.venv\Scripts\Activate.ps1
.\scripts\dev.ps1
```

Open docs:

```text
http://localhost:8001/docs
```

## Endpoints

- `GET /health`
- `POST /vision/face/detect`
- `POST /vision/face/embed`
- `POST /vision/face/verify`
- `POST /vision/text/ocr`
- `POST /audio/speech/transcribe`

All POST endpoints expect multipart field `file`.

## Development workflow

Run service:

```powershell
.\scripts\dev.ps1
```

Run tests:

```powershell
.\scripts\test.ps1
```

## Environment variables

- `ML_SERVICE_NAME`
- `ML_SERVICE_VERSION`
- `ML_SERVICE_HOST`
- `ML_SERVICE_PORT`
- `WHISPER_MODEL`
- `TESSERACT_CMD`
- `FACE_DETECTION_MODEL`
- `FACE_MATCH_THRESHOLD`

## Current baseline models

- face detection and embeddings: `face_recognition` with 128-d embeddings
- OCR: Tesseract via `pytesseract`
- speech-to-text: Whisper

## Next upgrade path

- replace `face_recognition` with `InsightFace` for stronger embeddings and easier scaling
- replace Tesseract with `PaddleOCR` for more robust OCR
- add chunking and VAD before Whisper for long audio
