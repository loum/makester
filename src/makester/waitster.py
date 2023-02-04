"""Wait until dependent service is ready.

"""
from typing import Text
import telnetlib

from logga import log
import backoff


@backoff.on_exception(
    backoff.constant,
    (OSError, EOFError, ConnectionRefusedError),
    max_time=300,
    interval=5,
)
def port_backoff(host: Text, port: int, detail: Text) -> None:
    """Service backoff until ready."""
    msg = f"Checking host:port {host}:{port}"
    if detail is not None:
        msg += f" {detail}"

    log.info("%s ...", msg)

    with telnetlib.Telnet(host, int(port)) as _tn:
        _tn.set_debuglevel(5)
        _tn.read_until(b" ", 1)
        log.info("Port %s ready", port)
