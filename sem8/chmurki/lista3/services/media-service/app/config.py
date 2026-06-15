from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads"
S3_BUCKET = os.getenv("S3_BUCKET", "")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
MEDIA_TABLE_NAME = os.getenv("MEDIA_TABLE_NAME", "media-metadata")
MAX_FILE_SIZE_BYTES = int(os.getenv("MAX_FILE_SIZE_BYTES", "10485760"))
FRONTEND_ORIGIN = os.getenv("FRONTEND_ORIGIN", "*")

COGNITO_REGION = os.getenv("COGNITO_REGION", AWS_REGION)
COGNITO_USER_POOL_ID = os.getenv("COGNITO_USER_POOL_ID", "")
COGNITO_CLIENT_ID = os.getenv("COGNITO_CLIENT_ID", "")
COGNITO_ENABLED = bool(COGNITO_USER_POOL_ID and COGNITO_CLIENT_ID)
