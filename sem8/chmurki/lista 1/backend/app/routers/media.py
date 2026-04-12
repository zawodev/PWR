from pathlib import Path
import uuid

import boto3
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session

from app.auth import get_current_user
from app.config import AWS_REGION, MAX_FILE_SIZE_BYTES, S3_BUCKET, UPLOAD_DIR
from app.db import get_db
from app.models import Media
from app.schemas import MediaOut

router = APIRouter(prefix="/api/media", tags=["media"])

s3_client = boto3.client("s3", region_name=AWS_REGION) if S3_BUCKET else None


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
async def upload_media(
    file: UploadFile = File(...),
    _current_user: dict[str, str] | None = Depends(get_current_user),
    db: Session = Depends(get_db),
):
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

    if s3_client is not None:
        try:
            s3_client.put_object(
                Bucket=S3_BUCKET,
                Key=stored_name,
                Body=raw,
                ContentType=content_type,
            )
        except Exception as exc:
            raise HTTPException(status_code=500, detail=f"S3 upload failed: {exc}") from exc
    else:
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

    if s3_client is not None:
        try:
            signed_url = s3_client.generate_presigned_url(
                "get_object",
                Params={
                    "Bucket": S3_BUCKET,
                    "Key": media.stored_name,
                    "ResponseContentType": media.content_type,
                    "ResponseContentDisposition": f'inline; filename="{media.original_name}"',
                },
                ExpiresIn=3600,
            )
            return RedirectResponse(url=signed_url)
        except Exception as exc:
            raise HTTPException(status_code=500, detail=f"S3 read failed: {exc}") from exc

    file_path = UPLOAD_DIR / media.stored_name
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Media file missing")

    return FileResponse(
        path=file_path,
        media_type=media.content_type,
        filename=media.original_name,
    )
