"""Logging configuration."""

from __future__ import annotations

import logging
import logging.config
import os
from typing import TYPE_CHECKING

import structlog

if TYPE_CHECKING:
    import structlog.stdlib


def suppress_logging() -> None:
    """Log level override (to level `CRITICAL`) suppression mechanism.

    This function can be useful when the need arises to temporarily throttle logging output down
    across the whole application.

    Technically, this function will disable all logging calls below severity level `CRITICAL`.

    """
    logging.disable(logging.ERROR)


timestamper = structlog.processors.TimeStamper(fmt="%Y-%m-%d %H:%M:%S")
pre_chain = [
    # Add the log level and a timestamp to the event_dict if the log entry
    # is not from structlog.
    structlog.stdlib.add_log_level,
    # Add extra attributes of LogRecord objects to the event dictionary
    # so that values passed in the extra parameter of log methods pass
    # through to log output.
    structlog.stdlib.ExtraAdder(),
    timestamper,
]


def extract_from_record(
    _: structlog.stdlib._FixedFindCallerLogger, __: str, event_dict: dict
) -> dict:
    """Extract thread and process names and add them to the event dict."""
    record = event_dict["_record"]
    event_dict["thread"] = record.threadName

    return event_dict


logging.config.dictConfig(
    {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "plain": {
                "()": structlog.stdlib.ProcessorFormatter,
                "processors": [
                    structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                    structlog.dev.ConsoleRenderer(colors=False),
                ],
                "foreign_pre_chain": pre_chain,
            },
            "colored": {
                "()": structlog.stdlib.ProcessorFormatter,
                "processors": [
                    extract_from_record,
                    structlog.stdlib.ProcessorFormatter.remove_processors_meta,
                    structlog.dev.ConsoleRenderer(colors=True),
                ],
                "foreign_pre_chain": pre_chain,
            },
        },
        "handlers": {
            "default": {
                "level": os.environ.get("LOG_LEVEL", "INFO").upper(),
                "class": "logging.StreamHandler",
                "formatter": "plain",
            },
        },
        "loggers": {
            "": {
                "handlers": ["default"],
                "level": os.environ.get("LOG_LEVEL", "INFO").upper(),
                "propagate": True,
            },
        },
    }
)
structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        timestamper,
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

log = structlog.get_logger("webapp")
