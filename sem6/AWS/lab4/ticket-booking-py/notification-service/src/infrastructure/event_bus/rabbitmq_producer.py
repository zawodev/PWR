import pika
import json
from ...infrastructure.config import settings

class RabbitMQProducer:
    def __init__(self):
        params = pika.URLParameters(settings.RABBITMQ_URL)
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()
        self.channel.exchange_declare(
            exchange=settings.RABBITMQ_EXCHANGE,
            exchange_type='topic',
            durable=True
        )

    def publish(self, routing_key: str, message: dict):
        self.channel.basic_publish(
            exchange=settings.RABBITMQ_EXCHANGE,
            routing_key=routing_key,
            body=json.dumps(message),
            properties=pika.BasicProperties(
                content_type='application/json',
                delivery_mode=2
            )
        )

producer = RabbitMQProducer()
