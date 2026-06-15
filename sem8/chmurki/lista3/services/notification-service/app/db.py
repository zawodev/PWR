import boto3

from app.config import AWS_REGION, NOTIFICATIONS_TABLE_NAME

_dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)


def get_notifications_table():
    return _dynamodb.Table(NOTIFICATIONS_TABLE_NAME)
