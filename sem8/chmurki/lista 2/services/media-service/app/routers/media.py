from datetime import datetime, timezone
from pathlib import Path
import uuid

import boto3
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from fastapi.responses import FileResponse, RedirectResponse

from app.auth import get_current_user
from app.config import AWS_REGION, MAX_FILE_SIZE_BYTES, S3_BUCKET, UPLOAD_DIR
from app.db import get_media_table
from app.schemas import MediaOut

router = APIRouter(prefix="/api/media", tags=["media"])

s3_client = boto3.client("s3", region_name=AWS_REGION) if S3_BUCKET else None


def _is_supported_content_type(content_type: str) -> bool:
    return (
        content_type.startswith("image/")
        or content_type.startswith("video/")
        or content_type.startswith("audio/")
    )


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _to_media_out(item: dict) -> MediaOut:
    return MediaOut(
        id=item["media_id"],
        original_name=item["original_name"],
        content_type=item["content_type"],
        size=int(item["size"]),
        created_at=item["created_at"],
        content_url=f"/api/media/{item['media_id']}/content",
    )


def _get_media_item(media_id: str) -> dict | None:
    table = get_media_table()
    response = table.get_item(Key={"media_id": media_id})
    return response.get("Item") if isinstance(response, dict) else None


@router.get("/health")
def health():
    return {"status": "ok"}


@router.post("", response_model=MediaOut)
async def upload_media(
    file: UploadFile = File(...),
    _current_user: dict[str, str] | None = Depends(get_current_user),
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
    media_id = uuid.uuid4().hex
    stored_name = f"{media_id}{suffix}"

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
        UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
        save_path = UPLOAD_DIR / stored_name
        save_path.write_bytes(raw)

    item = {
        "media_id": media_id,
        "original_name": file.filename or stored_name,
        "stored_name": stored_name,
        "content_type": content_type,
        "size": size,
        "created_at": _utc_now(),
    }

    table = get_media_table()
    table.put_item(Item=item)

    return _to_media_out(item)


@router.get("/{media_id}", response_model=MediaOut)
def get_media(media_id: str):
    item = _get_media_item(media_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Media not found")
    return _to_media_out(item)


@router.get("/{media_id}/content")
def get_media_content(media_id: str):
    item = _get_media_item(media_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Media not found")

    if s3_client is not None:
        try:
            signed_url = s3_client.generate_presigned_url(
                "get_object",
                Params={
                    "Bucket": S3_BUCKET,
                    "Key": item["stored_name"],
                    "ResponseContentType": item["content_type"],
                    "ResponseContentDisposition": f"inline; filename=\"{item['original_name']}\"",
                },
                ExpiresIn=3600,
            )
            return RedirectResponse(url=signed_url)
        except Exception as exc:
            raise HTTPException(status_code=500, detail=f"S3 read failed: {exc}") from exc

    file_path = UPLOAD_DIR / item["stored_name"]
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Media file missing")

    return FileResponse(
        path=file_path,
        media_type=item["content_type"],
        filename=item["original_name"],
    )
