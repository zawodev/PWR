from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = Path(os.getenv("DB_DIR", str(BASE_DIR / "db"))) / "chat.db"
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{DB_PATH.as_posix()}")
FRONTEND_ORIGIN = os.getenv("FRONTEND_ORIGIN", "*")
POLL_DEFAULT_LIMIT = int(os.getenv("POLL_DEFAULT_LIMIT", "50"))
MEDIA_SERVICE_URL = os.getenv("MEDIA_SERVICE_URL", "").rstrip("/")
NOTIFICATION_SERVICE_URL = os.getenv("NOTIFICATION_SERVICE_URL", "").rstrip("/")
NOTIFICATION_SHARED_SECRET = os.getenv("NOTIFICATION_SHARED_SECRET", "")
DEFAULT_CHAT_SLUG = os.getenv("DEFAULT_CHAT_SLUG", "global")

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
COGNITO_REGION = os.getenv("COGNITO_REGION", AWS_REGION)
COGNITO_USER_POOL_ID = os.getenv("COGNITO_USER_POOL_ID", "")
COGNITO_CLIENT_ID = os.getenv("COGNITO_CLIENT_ID", "")
COGNITO_ENABLED = bool(COGNITO_USER_POOL_ID and COGNITO_CLIENT_ID)
