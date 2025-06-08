import os
import io
import time
import uuid
import json
import qrcode
import boto3

# env vars
BUCKET = os.environ["BUCKET_NAME"]
REGION = os.environ["REGION_NAME"]

s3 = boto3.client("s3", region_name=REGION)

def lambda_handler(event, context):
    try:
        body = event.get("body")
        if body is None:
            return _response(400, {"error": "No body in request"})

        data = json.loads(body)
        url = data.get("url")
        if not url:
            return _response(400, {"error": "Field 'url' is required"})

        # generuj QR
        qr_img = qrcode.make(url)

        # serializuj do PNG w pamięci
        buf = io.BytesIO()
        qr_img.save(buf, format="PNG")
        buf.seek(0)

        # nazwij plik: timestamp + uuid4
        filename = f"{int(time.time())}_{uuid.uuid4().hex}.png"

        # wyślij do S3
        s3.put_object(
            Bucket=BUCKET,
            Key=filename,
            Body=buf,
            ContentType="image/png"
        )

        # publiczny URL
        url_out = f"https://{BUCKET}.s3.{REGION}.amazonaws.com/{filename}"
        return _response(200, {"qr_url": url_out})

    except Exception as e:
        return _response(500, {"error": str(e)})

def _response(status_code, body_dict):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body_dict)
    }
