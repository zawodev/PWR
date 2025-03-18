import pika
import logging
import json
import uuid

logger = logging.getLogger(__name__)

class RabbitMQBroker:
    EXCHANGE_NAME = "events_exchange"
    EXCHANGE_TYPE = "direct"

    def __init__(self, host='localhost', port=5672, username='guest', password='guest'):
        """
        start a connection with RabbitMQ and declare an exchange
        """
        # start connection
        credentials = pika.PlainCredentials(username, password)
        params = pika.ConnectionParameters(host=host, port=port, credentials=credentials)
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()

        # declare an exchange
        self.channel.exchange_declare(exchange=self.EXCHANGE_NAME, exchange_type=self.EXCHANGE_TYPE)
        logger.info("Połączono z RabbitMQ, zadeklarowano exchange: %s", self.EXCHANGE_NAME)

    def subscribe_and_consume(self, routing_key, callback):
        """
        1) declare a queue (with a unique name)
        2) bind it to the exchange with a given routing_key
        3) start consuming loop (start_consuming)
        """
        queue_name = f"{routing_key}_queue_{uuid.uuid4().hex[:6]}"
        self.channel.queue_declare(queue=queue_name, exclusive=True)
        self.channel.queue_bind(exchange=self.EXCHANGE_NAME, queue=queue_name, routing_key=routing_key)

        logger.info("Consumer subskrybuje routing_key=%s, queue=%s", routing_key, queue_name)

        # set the callback
        def on_message(ch, method, properties, body):
            msg = json.loads(body.decode('utf-8'))
            event_class_name = msg["event_class"]
            data = msg["data"]
            callback(event_class_name, data)

        self.channel.basic_consume(queue=queue_name, on_message_callback=on_message, auto_ack=True)

        try:
            self.channel.start_consuming()
        except KeyboardInterrupt:
            self.close()

    def publish(self, routing_key, event_obj):
        """
        publishing an event (serialized to JSON) with a given routing_key
        """
        # simple example:
        # {
        #   "event_class": "Type1Event",
        #   "data": "example data is put here",
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
        close the connection with RabbitMQ
        """
        self.connection.close()
        logger.info("Zamknięto połączenie z RabbitMQ")
