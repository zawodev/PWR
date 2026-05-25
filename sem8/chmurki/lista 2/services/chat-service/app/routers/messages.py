from fastapi import APIRouter, Depends, HTTPException, Query
import httpx
from sqlalchemy.orm import Session

from app.auth import get_current_user
from app.config import DEFAULT_CHAT_SLUG, MEDIA_SERVICE_URL, NOTIFICATION_SERVICE_URL, NOTIFICATION_SHARED_SECRET, POLL_DEFAULT_LIMIT
from app.db import get_db
from app.models import Chat, Message
from app.schemas import MediaOut, MessageCreate, MessageOut

router = APIRouter(prefix="/api", tags=["messages"])


def _get_default_chat(db: Session) -> Chat:
    chat = db.query(Chat).filter(Chat.slug == DEFAULT_CHAT_SLUG).first()
    if chat is not None:
        return chat

    chat = Chat(name="Global", slug=DEFAULT_CHAT_SLUG)
    db.add(chat)
    db.commit()
    db.refresh(chat)
    return chat


def _fetch_media(media_id: str) -> MediaOut | None:
    if not MEDIA_SERVICE_URL:
        return None

    try:
        response = httpx.get(f"{MEDIA_SERVICE_URL}/api/media/{media_id}", timeout=3.0)
    except httpx.HTTPError:
        return None

    if response.status_code == 404:
        return None
    if response.status_code >= 400:
        return None

    data = response.json()
    try:
        return MediaOut(**data)
    except Exception:
        return None


def _notify_new_message(chat: Chat, message: Message) -> None:
    if not NOTIFICATION_SERVICE_URL:
        return

    payload = {
        "title": f"New message in {chat.name}",
        "message": message.text or "Media message",
        "chat_id": chat.id,
        "sender": message.nickname,
    }

    headers = {}
    if NOTIFICATION_SHARED_SECRET:
        headers["X-Notification-Secret"] = NOTIFICATION_SHARED_SECRET

    try:
        response = httpx.post(
            f"{NOTIFICATION_SERVICE_URL}/api/notifications",
            json=payload,
            headers=headers,
            timeout=3.0,
        )
        if response.status_code >= 400:
            print(
                "Notification post failed",
                response.status_code,
                response.text[:200],
                flush=True,
            )
    except httpx.HTTPError as exc:
        print(f"Notification post exception: {exc}", flush=True)
        return


def _to_message_out(message: Message, media: MediaOut | None) -> MessageOut:
    return MessageOut(
        id=message.id,
        chat_id=message.chat_id,
        nickname=message.nickname,
        text=message.text,
        created_at=message.created_at,
        media=media,
    )


def _list_messages(chat: Chat, after_id: int | None, limit: int, db: Session) -> list[MessageOut]:
    query = db.query(Message).filter(Message.chat_id == chat.id).order_by(Message.id.asc())
    if after_id is not None:
        query = query.filter(Message.id > after_id)

    items = query.limit(limit).all()
    media_map: dict[str, MediaOut | None] = {}

    for item in items:
        if item.media_id and item.media_id not in media_map:
            media_map[item.media_id] = _fetch_media(item.media_id)

    return [_to_message_out(item, media_map.get(item.media_id)) for item in items]


@router.get("/messages", response_model=list[MessageOut])
def get_messages(
    after_id: int | None = Query(default=None, ge=0),
    limit: int = Query(default=POLL_DEFAULT_LIMIT, ge=1, le=200),
    _current_user: dict[str, str] | None = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    chat = _get_default_chat(db)
    return _list_messages(chat, after_id, limit, db)


@router.post("/messages", response_model=MessageOut)
def post_message(
    payload: MessageCreate,
    current_user: dict[str, str] | None = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    chat = _get_default_chat(db)
    return _create_message(chat, payload, current_user, db)


@router.get("/chats/{chat_id}/messages", response_model=list[MessageOut])
def get_chat_messages(
    chat_id: int,
    after_id: int | None = Query(default=None, ge=0),
    limit: int = Query(default=POLL_DEFAULT_LIMIT, ge=1, le=200),
    _current_user: dict[str, str] | None = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    chat = db.query(Chat).filter(Chat.id == chat_id).first()
    if chat is None:
        raise HTTPException(status_code=404, detail="Chat not found")
    return _list_messages(chat, after_id, limit, db)


@router.post("/chats/{chat_id}/messages", response_model=MessageOut)
def post_chat_message(
    chat_id: int,
    payload: MessageCreate,
    current_user: dict[str, str] | None = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    chat = db.query(Chat).filter(Chat.id == chat_id).first()
    if chat is None:
        raise HTTPException(status_code=404, detail="Chat not found")
    return _create_message(chat, payload, current_user, db)


def _create_message(
    chat: Chat,
    payload: MessageCreate,
    current_user: dict[str, str] | None,
    db: Session,
) -> MessageOut:
    trimmed_text = payload.text.strip()
    if not trimmed_text and payload.media_id is None:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    payload_nickname = (payload.nickname or "").strip()
    nickname = (current_user or {}).get("username", "").strip() or payload_nickname
    if not nickname:
        raise HTTPException(status_code=400, detail="Nickname cannot be empty")

    media = None
    if payload.media_id is not None:
        media = _fetch_media(payload.media_id)
        if media is None:
            raise HTTPException(status_code=404, detail="Media not found")

    message = Message(
        chat_id=chat.id,
        nickname=nickname,
        text=trimmed_text,
        media_id=payload.media_id,
    )
    db.add(message)
    db.commit()
    db.refresh(message)

    _notify_new_message(chat, message)

    return _to_message_out(message, media)
