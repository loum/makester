"""Makester CLI.

"""
import argparse
import telnetlib
import json
import logging

import backoff
import makester
import makester.templater

LOG = logging.getLogger("makester")
if not LOG.handlers:
    LOG.propagate = 0
    CONSOLE = logging.StreamHandler()
    LOG.addHandler(CONSOLE)
    FORMATTER = logging.Formatter("%(asctime)s:%(name)s:%(levelname)s: %(message)s")
    CONSOLE.setFormatter(FORMATTER)

LOG.setLevel(logging.INFO)

DESCRIPTION = """Makester CLI tool"""


def main():
    """Script entry point."""
    parser = argparse.ArgumentParser(
        prog=makester.__app_name__, description=DESCRIPTION
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help='Disable logs to screen (to log level "ERROR")',
    )

    # Add sub-command support.
    subparsers = parser.add_subparsers()

    # 'primer' subcommand.
    primer_parser = subparsers.add_parser("primer", help="Python project primer")

    # 'templater' subcommand.
    templater_parser = subparsers.add_parser("templater", help="Document templater")
    templater_parser.add_argument(
        "template",
        help=("Path to Jinja2 template " "(absolute, or relative to user home)"),
    )
    templater_parser.add_argument(
        "-f",
        "--filter",
        help=(
            "Environment variable filter "
            "(ignored when mapping is taken from JSON file)"
        ),
    )
    templater_parser.add_argument(
        "-m",
        "--mapping",
        help=("Optional path to JSON mappings " "(absolute, or relative to user home)"),
    )
    templater_parser.add_argument(
        "-w",
        "--write",
        action="store_true",
        help="Write out templated file alongside Jinja2 template",
    )
    templater_parser.set_defaults(func=render_template)

    # 'backoff' subcommand.
    backoff_parser = subparsers.add_parser(
        "backoff", help="Backoff until all ports ready"
    )
    backoff_parser.add_argument("host", help="Connection host")
    backoff_parser.add_argument("port", help="Backoff port number until ready")
    backoff_parser.add_argument(
        "-d",
        "--detail",
        default="Service",
        help="Meaningful description for backoff port",
    )
    backoff_parser.set_defaults(func=port_backoff)

    # Prepare the argument list.
    args = parser.parse_args()
    try:
        func = args.func
        if args.quiet:
            logging.disable(logging.ERROR)
    except AttributeError:
        parser.print_help()
        parser.exit()
    func(args)


def render_template(args):
    """Document templater."""
    mappings = {}
    if args.mapping:
        mappings.update(makester.templater.get_json_values(args.mapping))
    else:
        mappings.update(makester.templater.get_environment_values(token=(args.filter)))

    LOG.info("Template mapping values sourced:\n%s", json.dumps(mappings, indent=2))

    makester.templater.build_from_template(
        mappings, args.template, write_output=args.write
    )


@backoff.on_exception(
    backoff.constant,
    (OSError, EOFError, ConnectionRefusedError),
    max_time=300,
    interval=5,
)
def port_backoff(args):
    """Service backoff until ready."""
    msg = f"Checking host:port {args.host}:{args.port}"
    if args.detail is not None:
        msg += f" {args.detail}"

    LOG.info("%s ...", msg)

    with telnetlib.Telnet(args.host, int(args.port)) as _tn:
        _tn.set_debuglevel(5)
        _tn.read_until(b" ", 1)
        LOG.info("Port %s ready", args.port)
