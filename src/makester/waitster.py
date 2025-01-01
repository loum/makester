"""Wait until dependent service is ready."""

import asyncio

import backoff


async def wait_host_port(host: str, port: int) -> None:
    """Attempt a connection request of port on a host.

    Use the async library to attempt to open a connection

    Parameters
    ----------
        host: The IP address or hostname.
        port: Port number.

    """
    _, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout=2)
    writer.close()
    await writer.wait_closed()


@backoff.on_exception(
    backoff.constant,
    (OSError, EOFError, ConnectionRefusedError),
    max_time=300,
    interval=5,
)
def port_backoff(host: str, port: int, detail: str) -> None:
    """Service backoff until ready."""
    msg = f"Checking host:port {host}:{port}"
    if detail is not None:
        msg += f" {detail}"

    try:
        asyncio.run(wait_host_port(host, int(port)))
    finally:
        print(f"{msg} ...")

    print("Server is accepting connection requests 🚀")
