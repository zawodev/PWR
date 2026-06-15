import json
import os
import re
import uuid
import urllib.request
from datetime import datetime, timezone

import boto3
import psycopg2
import psycopg2.extras

# ── env ──────────────────────────────────────────────────────────────
DATABASE_URL = os.environ["DATABASE_URL"]
SQS_QUEUE_URL = os.environ.get("SQS_QUEUE_URL", "")
MEDIA_SERVICE_URL = os.environ.get("MEDIA_SERVICE_URL", "").rstrip("/")
DEFAULT_CHAT_SLUG = os.environ.get("DEFAULT_CHAT_SLUG", "global")

sqs = boto3.client("sqs", region_name=os.environ.get("AWS_REGION", "us-east-1"))


# ── helpers ──────────────────────────────────────────────────────────

def _fetch_media(media_id):
    if not media_id or not MEDIA_SERVICE_URL:
        return None
    url = f"{MEDIA_SERVICE_URL}/api/media/{media_id}"
    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=3) as response:
            if response.status == 200:
                return json.loads(response.read().decode("utf-8"))
    except Exception as exc:
        print(f"Failed to fetch media {media_id} from {url}: {exc}", flush=True)
    return None


def _dsn():
    """Parse DATABASE_URL into psycopg2 connect kwargs."""
    url = DATABASE_URL
    if url.startswith("postgresql://"):
        url = url[len("postgresql://"):]
    user_pass, rest = url.split("@", 1)
    user, password = user_pass.split(":", 1)
    host_port, dbname = rest.split("/", 1)
    if ":" in host_port:
        host, port = host_port.split(":", 1)
    else:
        host, port = host_port, "5432"
    return dict(host=host, port=int(port), dbname=dbname, user=user, password=password)


def _connect():
    return psycopg2.connect(**_dsn(), connect_timeout=5)


def _json_response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        },
        "body": json.dumps(body, default=str),
    }


def _slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "chat"


def _ensure_schema(conn):
    """Idempotent table creation – runs once per cold start at most."""
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS chats (
                id SERIAL PRIMARY KEY,
                name VARCHAR(120) NOT NULL,
                slug VARCHAR(80) NOT NULL UNIQUE,
                created_by VARCHAR(80),
                created_at TIMESTAMPTZ NOT NULL DEFAULT now()
            );
            CREATE TABLE IF NOT EXISTS messages (
                id SERIAL PRIMARY KEY,
                chat_id INTEGER NOT NULL REFERENCES chats(id),
                nickname VARCHAR(40) NOT NULL,
                text TEXT NOT NULL DEFAULT '',
                media_id VARCHAR(80),
                created_at TIMESTAMPTZ NOT NULL DEFAULT now()
            );
            CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
            CREATE TABLE IF NOT EXISTS chat_members (
                chat_id INTEGER NOT NULL REFERENCES chats(id),
                username VARCHAR(80) NOT NULL,
                joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
                PRIMARY KEY (chat_id, username)
            );
        """)
    conn.commit()


# ── SQS publish ──────────────────────────────────────────────────────

def _publish_notification(chat_name: str, message_text: str, chat_id: int, sender: str):
    """Publish a notification event to SQS for async processing."""
    if not SQS_QUEUE_URL:
        return

    # Unique message_id used for idempotent processing in the notification worker
    event = {
        "message_id": uuid.uuid4().hex,
        "title": f"New message in {chat_name}",
        "message": message_text or "Media message",
        "chat_id": chat_id,
        "sender": sender,
    }
    try:
        sqs.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=json.dumps(event))
    except Exception as exc:
        print(f"SQS publish failed: {exc}", flush=True)


# ── route handlers ───────────────────────────────────────────────────

def _handle_health(conn):
    return _json_response(200, {"status": "ok"})


def _handle_list_chats(conn):
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id, name, slug, created_by, created_at FROM chats ORDER BY id ASC")
        rows = cur.fetchall()
    return _json_response(200, rows)


def _handle_create_chat(conn, body, username):
    name = body.get("name", "").strip()
    if not name:
        return _json_response(400, {"detail": "Chat name is required"})

    slug = (body.get("slug") or _slugify(name)).strip()
    if not slug:
        slug = "chat"

    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id FROM chats WHERE slug = %s", (slug,))
        if cur.fetchone():
            return _json_response(409, {"detail": "Chat slug already exists"})

        cur.execute(
            "INSERT INTO chats (name, slug, created_by) VALUES (%s, %s, %s) RETURNING id, name, slug, created_by, created_at",
            (name, slug, username),
        )
        chat = cur.fetchone()

        # Creator auto-joins the chat
        cur.execute(
            "INSERT INTO chat_members (chat_id, username) VALUES (%s, %s) ON CONFLICT DO NOTHING",
            (chat["id"], username),
        )

    conn.commit()

    # System message about creation
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO messages (chat_id, nickname, text) VALUES (%s, %s, %s)",
            (chat["id"], "system", f"{username} created the chat"),
        )
    conn.commit()

    return _json_response(201, chat)


def _handle_get_chat(conn, chat_id):
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id, name, slug, created_by, created_at FROM chats WHERE id = %s", (chat_id,))
        chat = cur.fetchone()
    if not chat:
        return _json_response(404, {"detail": "Chat not found"})
    return _json_response(200, chat)


def _handle_list_messages(conn, chat_id, query_params):
    after_id = query_params.get("after_id")
    limit = min(int(query_params.get("limit", "50")), 200)

    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        if after_id:
            cur.execute(
                "SELECT id, chat_id, nickname, text, media_id, created_at FROM messages "
                "WHERE chat_id = %s AND id > %s ORDER BY id ASC LIMIT %s",
                (chat_id, int(after_id), limit),
            )
        else:
            cur.execute(
                "SELECT id, chat_id, nickname, text, media_id, created_at FROM messages "
                "WHERE chat_id = %s ORDER BY id ASC LIMIT %s",
                (chat_id, limit),
            )
        rows = cur.fetchall()

    for row in rows:
        if row.get("media_id"):
            row["media"] = _fetch_media(row["media_id"])
        else:
            row["media"] = None

    return _json_response(200, rows)


def _handle_create_message(conn, chat_id, body, username):
    text = body.get("text", "").strip()
    media_id = body.get("media_id")

    if not text and not media_id:
        return _json_response(400, {"detail": "Message cannot be empty"})

    nickname = username or body.get("nickname", "").strip()
    if not nickname:
        return _json_response(400, {"detail": "Nickname is required"})

    # Verify chat exists and get its name
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id, name FROM chats WHERE id = %s", (chat_id,))
        chat = cur.fetchone()

    if not chat:
        return _json_response(404, {"detail": "Chat not found"})

    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            "INSERT INTO messages (chat_id, nickname, text, media_id) "
            "VALUES (%s, %s, %s, %s) RETURNING id, chat_id, nickname, text, media_id, created_at",
            (chat_id, nickname, text, media_id),
        )
        message = cur.fetchone()
    conn.commit()

    _publish_notification(chat["name"], text, chat_id, nickname)

    if message.get("media_id"):
        message["media"] = _fetch_media(message["media_id"])
    else:
        message["media"] = None

    return _json_response(201, message)


def _handle_default_messages(conn, query_params, method, body, username):
    """GET/POST /api/messages – operates on the default 'global' chat."""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id FROM chats WHERE slug = %s", (DEFAULT_CHAT_SLUG,))
        row = cur.fetchone()
        if not row:
            cur.execute(
                "INSERT INTO chats (name, slug) VALUES (%s, %s) RETURNING id",
                ("Global", DEFAULT_CHAT_SLUG),
            )
            row = cur.fetchone()
            conn.commit()
        chat_id = row["id"]

    if method == "GET":
        return _handle_list_messages(conn, chat_id, query_params)
    else:
        return _handle_create_message(conn, chat_id, body, username)


# ── join / leave ─────────────────────────────────────────────────────

def _handle_join_chat(conn, chat_id, username):
    """POST /api/chats/{chat_id}/join – adds user as member and posts system message."""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id, name FROM chats WHERE id = %s", (chat_id,))
        chat = cur.fetchone()

    if not chat:
        return _json_response(404, {"detail": "Chat not found"})

    with conn.cursor() as cur:
        # ON CONFLICT → already a member, skip
        cur.execute(
            "INSERT INTO chat_members (chat_id, username) VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING chat_id",
            (chat_id, username),
        )
        inserted = cur.fetchone()

    if inserted:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO messages (chat_id, nickname, text) VALUES (%s, %s, %s)",
                (chat_id, "system", f"{username} joined the chat"),
            )
        conn.commit()

        _publish_notification(chat["name"], f"{username} joined the chat", chat_id, "system")

    conn.commit()
    return _json_response(200, {"status": "joined", "chat_id": chat_id})


def _handle_leave_chat(conn, chat_id, username):
    """POST /api/chats/{chat_id}/leave – removes user from members and posts system message."""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT id, name FROM chats WHERE id = %s", (chat_id,))
        chat = cur.fetchone()

    if not chat:
        return _json_response(404, {"detail": "Chat not found"})

    with conn.cursor() as cur:
        cur.execute(
            "DELETE FROM chat_members WHERE chat_id = %s AND username = %s RETURNING chat_id",
            (chat_id, username),
        )
        deleted = cur.fetchone()

    if deleted:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO messages (chat_id, nickname, text) VALUES (%s, %s, %s)",
                (chat_id, "system", f"{username} left the chat"),
            )
        conn.commit()

        _publish_notification(chat["name"], f"{username} left the chat", chat_id, "system")

    conn.commit()
    return _json_response(200, {"status": "left", "chat_id": chat_id})


def _handle_list_members(conn, chat_id):
    """GET /api/chats/{chat_id}/members"""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            "SELECT username, joined_at FROM chat_members WHERE chat_id = %s ORDER BY joined_at ASC",
            (chat_id,),
        )
        rows = cur.fetchall()
    return _json_response(200, rows)


def _handle_my_chats(conn, username):
    """GET /api/chats/my – return chats the user is a member of."""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            "SELECT c.id, c.name, c.slug, c.created_by, c.created_at "
            "FROM chats c INNER JOIN chat_members m ON c.id = m.chat_id "
            "WHERE m.username = %s ORDER BY c.id ASC",
            (username,),
        )
        rows = cur.fetchall()
    return _json_response(200, rows)


# ── router ───────────────────────────────────────────────────────────

def _extract_username(event):
    """Try to extract username from JWT claims injected by API Gateway authorizer or from query."""
    # API Gateway JWT authorizer claims
    claims = (event.get("requestContext", {}).get("authorizer", {}) or {}).get("jwt", {}).get("claims", {})
    username = claims.get("cognito:username") or claims.get("username") or claims.get("sub", "")
    if username:
        return username

    # Fallback: custom header (for internal/testing use)
    headers = event.get("headers", {}) or {}
    return headers.get("x-username", "guest")


def lambda_handler(event, context):
    """Main entry point – routes API Gateway v2 HTTP events to handler functions."""
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
    raw_path = event.get("rawPath", "/")
    query_params = event.get("queryStringParameters") or {}

    # Handle CORS pre-flight
    if method == "OPTIONS":
        return _json_response(200, {})

    body = {}
    if event.get("body"):
        try:
            body = json.loads(event["body"])
        except (json.JSONDecodeError, TypeError):
            body = {}

    username = _extract_username(event)

    conn = _connect()
    try:
        _ensure_schema(conn)

        # ── /api/chats/health ─────────────────────────
        if raw_path == "/api/chats/health":
            return _handle_health(conn)

        # ── /api/chats/my ─────────────────────────────
        if raw_path == "/api/chats/my" and method == "GET":
            return _handle_my_chats(conn, username)

        # ── /api/chats/{id}/join ──────────────────────
        m = re.match(r"^/api/chats/(\d+)/join$", raw_path)
        if m and method == "POST":
            return _handle_join_chat(conn, int(m.group(1)), username)

        # ── /api/chats/{id}/leave ─────────────────────
        m = re.match(r"^/api/chats/(\d+)/leave$", raw_path)
        if m and method == "POST":
            return _handle_leave_chat(conn, int(m.group(1)), username)

        # ── /api/chats/{id}/members ───────────────────
        m = re.match(r"^/api/chats/(\d+)/members$", raw_path)
        if m and method == "GET":
            return _handle_list_members(conn, int(m.group(1)))

        # ── /api/chats/{id}/messages ──────────────────
        m = re.match(r"^/api/chats/(\d+)/messages$", raw_path)
        if m:
            chat_id = int(m.group(1))
            if method == "GET":
                return _handle_list_messages(conn, chat_id, query_params)
            elif method == "POST":
                return _handle_create_message(conn, chat_id, body, username)

        # ── /api/chats/{id} ──────────────────────────
        m = re.match(r"^/api/chats/(\d+)$", raw_path)
        if m and method == "GET":
            return _handle_get_chat(conn, int(m.group(1)))

        # ── /api/chats ───────────────────────────────
        if raw_path == "/api/chats":
            if method == "GET":
                return _handle_list_chats(conn)
            elif method == "POST":
                return _handle_create_chat(conn, body, username)

        # ── /api/messages (default chat) ─────────────
        if raw_path == "/api/messages":
            return _handle_default_messages(conn, query_params, method, body, username)

        return _json_response(404, {"detail": "Not found"})

    except Exception as exc:
        print(f"Lambda error: {exc}", flush=True)
        return _json_response(500, {"detail": str(exc)})
    finally:
        conn.close()
