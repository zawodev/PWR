import boto3

from app.config import AWS_REGION, AUTH_TABLE_NAME

_dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)


def get_auth_table():
    return _dynamodb.Table(AUTH_TABLE_NAME)
