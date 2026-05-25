from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import DATABASE_URL, DB_PATH, DEFAULT_CHAT_SLUG, FRONTEND_ORIGIN
from app.db import Base, SessionLocal, engine
from app.models import Chat
from app.routers.chats import router as chats_router
from app.routers.messages import router as messages_router

app = FastAPI(title="Chat Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[FRONTEND_ORIGIN] if FRONTEND_ORIGIN != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    if DATABASE_URL.startswith("sqlite"):
        DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        chat = db.query(Chat).filter(Chat.slug == DEFAULT_CHAT_SLUG).first()
        if chat is None:
            db.add(Chat(name="Global", slug=DEFAULT_CHAT_SLUG))
            db.commit()
    finally:
        db.close()


app.include_router(chats_router)
app.include_router(messages_router)
