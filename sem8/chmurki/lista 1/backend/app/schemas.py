from datetime import datetime

from pydantic import BaseModel, Field


class MediaOut(BaseModel):
    id: int
    original_name: str
    content_type: str
    size: int
    created_at: datetime
    content_url: str

    model_config = {"from_attributes": True}


class MessageCreate(BaseModel):
    nickname: str | None = Field(default=None, min_length=1, max_length=40)
    text: str = Field(default="", max_length=2000)
    media_id: int | None = None


class MessageOut(BaseModel):
    id: int
    nickname: str
    text: str
    created_at: datetime
    media: MediaOut | None = None

    model_config = {"from_attributes": True}


class AuthConfigOut(BaseModel):
    enabled: bool


class AuthLoginIn(BaseModel):
    username: str = Field(min_length=1, max_length=128)
    password: str = Field(min_length=1, max_length=256)


class AuthRegisterIn(BaseModel):
    username: str = Field(min_length=1, max_length=128)
    password: str = Field(min_length=1, max_length=256)


class AuthLoginOut(BaseModel):
    access_token: str
    refresh_token: str | None = None
    id_token: str | None = None
    token_type: str = "Bearer"
    expires_in: int
    username: str


class AuthUserOut(BaseModel):
    username: str
