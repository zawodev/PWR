import json
import threading
import time
import traceback
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

from app.config import (
    AWS_REGION,
    SNS_TOPIC_ARN,
    SQS_MAX_MESSAGES,
    SQS_POLL_WAIT_SECONDS,
    SQS_QUEUE_URL,
)
from app.db import get_notifications_table

sqs_client = boto3.client("sqs", region_name=AWS_REGION)
sns_client = boto3.client("sns", region_name=AWS_REGION)

_stop_event = threading.Event()


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _process_message(raw_body: str) -> None:
    event = json.loads(raw_body)

    notification_id = event.get("message_id") or event.get("notification_id")
    if not notification_id:
        print("SQS message missing message_id, skipping", flush=True)
        return

    title = event.get("title", "Notification")
    message = event.get("message", "")
    chat_id = event.get("chat_id")
    sender = event.get("sender")

    if "fortepian" in message.lower():
        raise ValueError("simulated processing failure: message contains 'fortepian'")

    item = {
        "notification_id": notification_id,
        "title": title,
        "message": message,
        "created_at": _utc_now(),
        "chat_id": chat_id,
        "sender": sender,
        "status": "sent",
    }

    # idempotent DynamoDB put – only succeeds if notification_id does not exist yet
    table = get_notifications_table()
    try:
        table.put_item(
            Item={k: v for k, v in item.items() if v is not None},
            ConditionExpression="attribute_not_exists(notification_id)",
        )
    except ClientError as exc:
        if exc.response["Error"]["Code"] == "ConditionalCheckFailedException":
            print(f"Duplicate notification {notification_id}, acknowledging without re-sending", flush=True)
            return
        raise

    # Publish to SNS only when DynamoDB write succeeded (no duplicate)
    if SNS_TOPIC_ARN:
        try:
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(item, ensure_ascii=True),
                Subject=title[:99],
            )
        except Exception as exc:
            print(f"SNS publish failed for {notification_id}: {exc}", flush=True)


def _poll_loop() -> None:
    # long-poll SQS in a loop until _stop_event is set.
    print(f"SQS worker started – queue={SQS_QUEUE_URL}", flush=True)

    while not _stop_event.is_set():
        try:
            response = sqs_client.receive_message(
                QueueUrl=SQS_QUEUE_URL,
                MaxNumberOfMessages=SQS_MAX_MESSAGES,
                WaitTimeSeconds=SQS_POLL_WAIT_SECONDS,
            )
        except Exception as exc:
            print(f"SQS receive error: {exc}", flush=True)
            time.sleep(5)
            continue

        messages = response.get("Messages", [])
        for msg in messages:
            receipt_handle = msg["ReceiptHandle"]
            try:
                _process_message(msg["Body"])
                sqs_client.delete_message(
                    QueueUrl=SQS_QUEUE_URL,
                    ReceiptHandle=receipt_handle,
                )
            except Exception:
                # don't delete → SQS will retry; after maxReceiveCount → DLQ
                traceback.print_exc()
                print(f"Failed to process message {msg.get('MessageId')}, will retry", flush=True)


def start_worker() -> threading.Thread | None:
    """Launch the SQS polling thread. Returns None if SQS is not configured."""
    if not SQS_QUEUE_URL:
        print("SQS_QUEUE_URL not set – SQS worker disabled", flush=True)
        return None

    thread = threading.Thread(target=_poll_loop, name="sqs-worker", daemon=True)
    thread.start()
    return thread


def stop_worker() -> None:
    _stop_event.set()
