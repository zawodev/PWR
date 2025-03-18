import logging
import re
from rabbitmq_broker import RabbitMQBroker

logger = logging.getLogger(__name__)

class PublisherBase:
    def __init__(self, event_class):
        """
        :param event_class: klasa zdarzenia, np. Type1Event
        """
        self.event_class = event_class
        self.channel_name = self._derive_channel_name(event_class)

        # Każdy publisher tworzy sobie własny broker
        # (w realnym systemie można by to współdzielić lub wstrzykiwać)
        self.broker = RabbitMQBroker()

    def _derive_channel_name(self, event_class):
        """
        Zamienia np. 'Type1Event' na 'type1'.
        """
        class_name = event_class.__name__
        base_name = re.sub(r'Event$', '', class_name)
        return base_name.lower()

    def publish(self, data):
        """
        Publikuje instancję eventu do RabbitMQ.
        """
        event_instance = self.event_class(data)
        logger.info("Publisher %s publikuje event: %s", self.__class__.__name__, event_instance.__class__.__name__)
        self.broker.publish(self.channel_name, event_instance)
