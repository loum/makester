"""Makester CLI.

"""
import argparse

DESCRIPTION = """Makester CLI tool"""


def main():
    """Script entry point.

    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    # Add sub-command support.
    subparsers = parser.add_subparsers()

    # 'primer' subcommand.
    primer_parser = subparsers.add_parser('primer', help='Makester Python project primer')

    # Prepare the argument list.
    args = parser.parse_args()
    try:
        func = args.func
    except AttributeError:
        parser.print_help()
        parser.exit()
    func(args)
