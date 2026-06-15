from pydantic import BaseModel, Field


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


class AuthProfileOut(BaseModel):
    username: str
    created_at: str | None = None
    last_login: str | None = None
