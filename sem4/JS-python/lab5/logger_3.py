import logging
import sys

# logger
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s; %(levelname)s: %(message)s')

# stdout handler
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)
stdout_handler.setFormatter(formatter)
logger.addHandler(stdout_handler)
class ErrorCriticalFilter(logging.Filter): # filter ERROR and CRITICAL for stdout
    def filter(self, record):
        return record.levelno < logging.ERROR  # returns True for levels lower than ERROR

stdout_handler.addFilter(ErrorCriticalFilter())  # adds the filter to stdout

# stderr handler
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.ERROR)
stderr_handler.setFormatter(formatter)
logger.addHandler(stderr_handler)

# basic log set for debug
logging.basicConfig(level=logging.DEBUG)

def log_the_log_file(log_file):
    for log_line in log_file:
        message_type = log_line['msg_type']

        logging.debug(f"read {len(log_line['line'])} bytes from log line")

        if message_type in ["accepted password for", "connection closed by"]:
            logging.info(message_type)
        elif message_type == "failed password for":
            logging.warning(message_type)
        elif message_type in ["authentication failure", "invalid user"]:
            logging.error(message_type)
        elif message_type == "possible break-in attempt":
            logging.critical(message_type)
        else:
            logging.debug("other message type")
