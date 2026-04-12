from fastapi import APIRouter, Depends

from app.auth import auth_is_enabled, get_current_user, login_with_password, register_with_password
from app.schemas import AuthConfigOut, AuthLoginIn, AuthLoginOut, AuthRegisterIn, AuthUserOut

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.get("/config", response_model=AuthConfigOut)
def get_auth_config():
    return AuthConfigOut(enabled=auth_is_enabled())


@router.post("/login", response_model=AuthLoginOut)
def login(payload: AuthLoginIn):
    return AuthLoginOut(**login_with_password(payload.username, payload.password))


@router.post("/register", response_model=AuthLoginOut)
def register(payload: AuthRegisterIn):
    return AuthLoginOut(**register_with_password(payload.username, payload.password))


@router.get("/me", response_model=AuthUserOut)
def get_me(current_user: dict[str, str] | None = Depends(get_current_user)):
    if current_user is None:
        return AuthUserOut(username="anonymous")
    return AuthUserOut(username=current_user["username"])
