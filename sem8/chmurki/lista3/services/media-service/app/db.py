import boto3

from app.config import AWS_REGION, MEDIA_TABLE_NAME

_dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)


def get_media_table():
    return _dynamodb.Table(MEDIA_TABLE_NAME)
