from pathlib import Path
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.config import MAX_FILE_SIZE_BYTES, UPLOAD_DIR
from app.db import get_db
from app.models import Media
from app.schemas import MediaOut

router = APIRouter(prefix="/api/media", tags=["media"])


def _is_supported_content_type(content_type: str) -> bool:
    return (
        content_type.startswith("image/")
        or content_type.startswith("video/")
        or content_type.startswith("audio/")
    )


def _to_media_out(media: Media) -> MediaOut:
    return MediaOut(
        id=media.id,
        original_name=media.original_name,
        content_type=media.content_type,
        size=media.size,
        created_at=media.created_at,
        content_url=f"/api/media/{media.id}/content",
    )


@router.post("", response_model=MediaOut)
async def upload_media(file: UploadFile = File(...), db: Session = Depends(get_db)):
    content_type = (file.content_type or "").lower()
    if not _is_supported_content_type(content_type):
        raise HTTPException(status_code=400, detail="Only image/audio/video files are allowed")

    raw = await file.read()
    size = len(raw)
    if size == 0:
        raise HTTPException(status_code=400, detail="File is empty")
    if size > MAX_FILE_SIZE_BYTES:
        raise HTTPException(status_code=400, detail="File too large")

    suffix = Path(file.filename or "").suffix
    stored_name = f"{uuid.uuid4().hex}{suffix}"
    save_path = UPLOAD_DIR / stored_name
    save_path.write_bytes(raw)

    media = Media(
        original_name=file.filename or stored_name,
        stored_name=stored_name,
        content_type=content_type,
        size=size,
    )
    db.add(media)
    db.commit()
    db.refresh(media)

    return _to_media_out(media)


@router.get("/{media_id}", response_model=MediaOut)
def get_media(media_id: int, db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.id == media_id).first()
    if media is None:
        raise HTTPException(status_code=404, detail="Media not found")
    return _to_media_out(media)


@router.get("/{media_id}/content")
def get_media_content(media_id: int, db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.id == media_id).first()
    if media is None:
        raise HTTPException(status_code=404, detail="Media not found")

    file_path = UPLOAD_DIR / media.stored_name
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Media file missing")

    return FileResponse(
        path=file_path,
        media_type=media.content_type,
        filename=media.original_name,
    )
