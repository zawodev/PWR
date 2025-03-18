import pika
import logging
import json

logger = logging.getLogger(__name__)

class RabbitMQBroker:
    EXCHANGE_NAME = "events_exchange"
    EXCHANGE_TYPE = "direct"

    def __init__(self, host='localhost', port=5672, username='guest', password='guest'):
        """
        Nawiązujemy połączenie z RabbitMQ i deklarujemy exchange.
        """
        credentials = pika.PlainCredentials(username, password)
        params = pika.ConnectionParameters(host=host, port=port, credentials=credentials)
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()

        # Deklarujemy exchange (typu direct)
        self.channel.exchange_declare(exchange=self.EXCHANGE_NAME, exchange_type=self.EXCHANGE_TYPE)
        logger.info("Połączono z RabbitMQ, zadeklarowano exchange: %s", self.EXCHANGE_NAME)

    def publish(self, routing_key, event_obj):
        """
        Publikujemy event (serializowany do JSON) z danym routing_key.
        """
        # W prostym przykładzie w wiadomości zapiszemy:
        # {
        #   "event_class": "Type1Event",
        #   "data": "...",
        # }
        message = {
            "event_class": event_obj.__class__.__name__,
            "data": event_obj.data
        }
        body = json.dumps(message).encode('utf-8')

        self.channel.basic_publish(
            exchange=self.EXCHANGE_NAME,
            routing_key=routing_key,
            body=body
        )
        logger.info("Wysłano event %s na routing_key=%s", event_obj.__class__.__name__, routing_key)

    def close(self):
        """
        Zamykamy połączenie z RabbitMQ.
        """
        self.connection.close()
        logger.info("Zamknięto połączenie z RabbitMQ")
