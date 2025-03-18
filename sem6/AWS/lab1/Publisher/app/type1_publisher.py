import time
import logging
import argparse
from publisher_base import PublisherBase
from Publisher.domain.events.type1_event import Type1Event

logger = logging.getLogger(__name__)

class Type1Publisher(PublisherBase):
    def __init__(self, publisher_id, interval=2):
        super().__init__(Type1Event)
        self.publisher_id = publisher_id
        self.interval = interval

    def run(self):
        while True:
            data = f"Type1 data from publisher {self.publisher_id}"
            self.publish(data)
            time.sleep(self.interval)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", type=int, default=1, help="ID publishera")
    parser.add_argument("--interval", type=int, default=2, help="Interwał publikacji")
    args = parser.parse_args()
    
    pub = Type1Publisher(publisher_id=args.id, interval=args.interval)
    logging.basicConfig(level=logging.INFO, format=f'[Type1Publisher{pub.publisher_id}] %(asctime)s %(name)s %(levelname)s: %(message)s')

    try:
        pub.run()
    except KeyboardInterrupt:
        pub.broker.close()
        print("stopped type1 publisher")

if __name__ == "__main__":
    main()
