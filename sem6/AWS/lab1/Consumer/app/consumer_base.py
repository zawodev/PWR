import logging
import re
from rabbitmq_broker import RabbitMQBroker

logger = logging.getLogger(__name__)

class ConsumerBase:
    def __init__(self, event_class):
        self.event_class = event_class
        self.channel_name = self._derive_channel_name(event_class)

        self.broker = RabbitMQBroker()

    def _derive_channel_name(self, event_class):
        class_name = event_class.__name__
        return re.sub(r'Event$', '', class_name).lower()

    def run(self):
        """
        subscribes itself to the broker and starts consuming messages
        """
        logger.info("Consumer %s czeka na zdarzenia typu %s (kanał: %s)",
                    self.__class__.__name__, self.event_class.__name__, self.channel_name)
        self.broker.subscribe_and_consume(self.channel_name, self._on_message)

    def _on_message(self, event_class_name, data):
        """
        callback is called when a message is received
        here we decide if the event class is correct (in a simple example, checking the names is enough)
        """
        if event_class_name == self.event_class.__name__:
            # create an instance of the event class
            event_obj = self.event_class(data)
            logger.info("Consumer %s otrzymał event: %s", self.__class__.__name__, event_class_name)
            self.process(event_obj)
        else:
            logger.warning("Odebrano event innego typu: %s (oczekiwano %s)", event_class_name, self.event_class.__name__)

    def process(self, event):
        """
        event logic – to be overridden in subclasses.
        """
        raise NotImplementedError
