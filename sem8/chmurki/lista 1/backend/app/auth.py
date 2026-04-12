from typing import Any

import boto3
from fastapi import Header, HTTPException

from app.config import COGNITO_CLIENT_ID, COGNITO_ENABLED, COGNITO_REGION, COGNITO_USER_POOL_ID

cognito_client = boto3.client("cognito-idp", region_name=COGNITO_REGION) if COGNITO_ENABLED else None


def auth_is_enabled() -> bool:
    return COGNITO_ENABLED


def _get_bearer_token(authorization: str | None) -> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    return token.strip()


def login_with_password(username: str, password: str) -> dict[str, Any]:
    if not COGNITO_ENABLED or cognito_client is None:
        raise HTTPException(status_code=503, detail="Cognito authentication is disabled")

    try:
        response = cognito_client.initiate_auth(
            AuthFlow="USER_PASSWORD_AUTH",
            ClientId=COGNITO_CLIENT_ID,
            AuthParameters={
                "USERNAME": username,
                "PASSWORD": password,
            },
        )
    except cognito_client.exceptions.NotAuthorizedException:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    except cognito_client.exceptions.UserNotFoundException:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    except cognito_client.exceptions.UserNotConfirmedException:
        raise HTTPException(status_code=403, detail="User is not confirmed")
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Cognito login failed: {exc}")

    auth_result = response.get("AuthenticationResult")
    if not auth_result:
        challenge = response.get("ChallengeName", "UNKNOWN")
        raise HTTPException(status_code=400, detail=f"Unsupported auth challenge: {challenge}")

    return {
        "access_token": auth_result.get("AccessToken", ""),
        "refresh_token": auth_result.get("RefreshToken"),
        "id_token": auth_result.get("IdToken"),
        "token_type": auth_result.get("TokenType", "Bearer"),
        "expires_in": int(auth_result.get("ExpiresIn", 3600)),
        "username": username,
    }


def register_with_password(username: str, password: str) -> dict[str, Any]:
    if not COGNITO_ENABLED or cognito_client is None:
        raise HTTPException(status_code=503, detail="Cognito authentication is disabled")

    if not COGNITO_USER_POOL_ID:
        raise HTTPException(status_code=503, detail="Cognito user pool is not configured")

    try:
        response = cognito_client.sign_up(
            ClientId=COGNITO_CLIENT_ID,
            Username=username,
            Password=password,
        )
    except cognito_client.exceptions.UsernameExistsException:
        raise HTTPException(status_code=409, detail="Username is already taken")
    except cognito_client.exceptions.InvalidPasswordException as exc:
        detail = exc.response.get("Error", {}).get("Message", "Password does not meet policy")
        raise HTTPException(status_code=400, detail=detail)
    except cognito_client.exceptions.InvalidParameterException as exc:
        detail = exc.response.get("Error", {}).get("Message", "Invalid registration payload")
        raise HTTPException(status_code=400, detail=detail)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Cognito register failed: {exc}")

    if not response.get("UserConfirmed", False):
        try:
            cognito_client.admin_confirm_sign_up(
                UserPoolId=COGNITO_USER_POOL_ID,
                Username=username,
            )
        except Exception as exc:
            raise HTTPException(status_code=500, detail=f"User created but auto-confirm failed: {exc}")

    return login_with_password(username, password)


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
