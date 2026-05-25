import boto3
from fastapi import Header, HTTPException

from app.config import COGNITO_ENABLED, COGNITO_REGION

cognito_client = boto3.client("cognito-idp", region_name=COGNITO_REGION) if COGNITO_ENABLED else None


def _get_bearer_token(authorization: str | None) -> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    return token.strip()


def get_current_user(authorization: str | None = Header(default=None)) -> dict[str, str] | None:
    if not COGNITO_ENABLED or cognito_client is None:
        return None

    token = _get_bearer_token(authorization)

    try:
        response = cognito_client.get_user(AccessToken=token)
    except cognito_client.exceptions.NotAuthorizedException:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    except Exception as exc:
        raise HTTPException(status_code=401, detail=f"Token verification failed: {exc}")

    attributes = {item.get("Name"): item.get("Value", "") for item in response.get("UserAttributes", [])}
    username = response.get("Username") or attributes.get("preferred_username") or attributes.get("email")
    if not username:
        raise HTTPException(status_code=401, detail="Unable to resolve user identity")

    return {
        "username": username,
        "sub": attributes.get("sub", ""),
    }
