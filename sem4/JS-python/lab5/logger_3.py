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


def check_log_level(log_level, min_log_level):
    log_levels = {
        'DEBUG': 0,
        'INFO': 1,
        'WARNING': 2,
        'ERROR': 3,
        'CRITICAL': 4,
        'NONE': 5
    }
    log_level_int = log_levels[log_level]
    min_log_level_int = log_levels[min_log_level]

    if min_log_level_int <= log_level_int:
        return True
    else:
        return False


def log_the_log_file(log_file, min_log_level):
    for log_line in log_file:
        message_type = log_line['msg_type']

        if check_log_level('DEBUG', min_log_level):
            logging.debug(f"read {len(log_line['line'])} bytes from log line")

        if check_log_level('INFO', min_log_level) and message_type in ["accepted password for", "connection closed by"]:
            logging.info(message_type)
        elif check_log_level('WARNING', min_log_level) and message_type == "failed password for":
            logging.warning(message_type)
        elif check_log_level('ERROR', min_log_level) and message_type in ["authentication failure", "invalid user"]:
            logging.error(message_type)
        elif check_log_level('CRITICAL', min_log_level) and message_type == "possible break-in attempt":
            logging.critical(message_type)
