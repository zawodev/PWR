from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads"
DB_PATH = Path(os.getenv("DB_DIR", str(BASE_DIR / "db"))) / "chat.db"
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{DB_PATH.as_posix()}")
FRONTEND_ORIGIN = os.getenv("FRONTEND_ORIGIN", "*")
MAX_FILE_SIZE_BYTES = int(os.getenv("MAX_FILE_SIZE_BYTES", "10485760"))
POLL_DEFAULT_LIMIT = int(os.getenv("POLL_DEFAULT_LIMIT", "50"))
S3_BUCKET = os.getenv("S3_BUCKET", "")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
