import re

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.models import Chat
from app.schemas import ChatCreate, ChatOut

router = APIRouter(prefix="/api/chats", tags=["chats"])


def _slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "chat"


@router.get("/health")
def health():
    return {"status": "ok"}


@router.get("", response_model=list[ChatOut])
def list_chats(db: Session = Depends(get_db)):
    return db.query(Chat).order_by(Chat.id.asc()).all()


@router.post("", response_model=ChatOut)
def create_chat(payload: ChatCreate, db: Session = Depends(get_db)):
    slug = (payload.slug or _slugify(payload.name)).strip()
    if not slug:
        slug = "chat"

    existing = db.query(Chat).filter(Chat.slug == slug).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="Chat slug already exists")

    chat = Chat(name=payload.name.strip(), slug=slug)
    db.add(chat)
    db.commit()
    db.refresh(chat)

    return chat


@router.get("/{chat_id}", response_model=ChatOut)
def get_chat(chat_id: int, db: Session = Depends(get_db)):
    chat = db.query(Chat).filter(Chat.id == chat_id).first()
    if chat is None:
        raise HTTPException(status_code=404, detail="Chat not found")
    return chat
