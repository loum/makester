"""Wait until a nominated services accepts connections.

"""
import sys
import telnetlib
import argparse
import logging
import backoff

LOG = logging.getLogger('waitster')
if not LOG.handlers:
    LOG.propagate = 0
    CONSOLE = logging.StreamHandler()
    LOG.addHandler(CONSOLE)
    FORMATTER = logging.Formatter('%(asctime)s:%(name)s:%(levelname)s: %(message)s')
    CONSOLE.setFormatter(FORMATTER)

LOG.setLevel(logging.INFO)

DESCRIPTION = """Backoff until all ports ready"""

def main():
    """Script entry point.

    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument('-p', '--port',
                        help='Backoff port number until ready',
                        required=True)
    parser.add_argument('-d', '--detail',
                        default='Service',
                        help='Meaningful description for backoff port')
    parser.add_argument('host',
                        default='localhost',
                        help='Connection host')

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    _backoff(args.host, args.port, args.detail)


@backoff.on_exception(backoff.constant,
                      (EOFError, ConnectionRefusedError),
                      max_time=300,
                      interval=5)
def _backoff(host, port, description=None):
    """Service backoff until ready.

    """
    msg = f'Checking host:port {host}:{port}'
    if description:
        msg += f' {description}'

    logging.info('%s ...')

    with telnetlib.Telnet(host, int(port)) as _tn:
        _tn.set_debuglevel(5)
        _tn.read_until(b' ', 1)
        logging.info('Port %s ready', port)


if __name__ == "__main__":
    main()
