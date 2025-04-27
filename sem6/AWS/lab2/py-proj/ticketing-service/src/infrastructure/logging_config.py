import logging

try:
    import colorlog
except ImportError:
    colorlog = None


def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    handler = logging.StreamHandler()

    if colorlog:
        formatter = colorlog.ColoredFormatter(
            fmt=(
                '%(log_color)s[%(name)s]'
                ' %(blue)s%(asctime)s '
                '%(log_color)s%(levelname)s: '
                '%(message_log_color)s%(message)s'
            ),
            datefmt='%H:%M:%S',
            log_colors={
                'DEBUG':    'cyan',
                'INFO':     'green',
                'WARNING':  'yellow',
                'ERROR':    'red',
                'CRITICAL': 'bold_red',
            },
            secondary_log_colors={
                'message': {
                    'DEBUG':    'white',
                    'INFO':     'white',
                    'WARNING':  'white',
                    'ERROR':    'white',
                    'CRITICAL': 'white',
                }
            },
            style='%'
        )
    else:
        formatter = logging.Formatter(
            '[%(name)s] %(asctime)s %(levelname)s: %(message)s',
            datefmt='%H:%M:%S'
        )

    handler.setFormatter(formatter)
    logger.addHandler(handler)
