"""Makester CLI.

"""
import json
from dataclasses import dataclass

import typer
from .logging_config import log, suppress_logging

import makester.templater
import makester.waitster

app = typer.Typer(
    add_completion=False,
    help="Makester CLI tool",
)


@dataclass
class Common:
    """Common arguments at the command level."""

    quiet: bool


@app.command()
def templater(
    template: str = typer.Argument(
        ...,
        help="Path to Jinja2 template (absolute, or relative to user home)",
        show_default=False,
    ),
    env_filter: str = typer.Option(
        None,
        "--filter",
        "-f",
        help="Environment variable filter (ignored when mapping is taken from JSON file)",
        show_default=False,
    ),
    mapping: str = typer.Option(
        None,
        "--mapping",
        "-m",
        help="path to JSON mappings (absolute, or relative to user home)",
        show_default=False,
    ),
    write: bool = typer.Option(
        False,
        "--write",
        "-w",
        help="Write out templated file alongside Jinja2 template",
    ),
) -> None:
    """Template against environment variables or optional JSON values."""
    mappings = {}
    if mapping:
        mappings.update(makester.templater.get_json_values(mapping))
    else:
        mappings.update(makester.templater.get_environment_values(token=env_filter))

    log.info("Template mapping values sourced:\n%s", json.dumps(mappings, indent=2))

    makester.templater.build_from_template(mappings, template, write_output=write)


@app.command()
def backoff(
    host: str = typer.Argument(
        ..., help="Host name of service connection.", show_default=False
    ),
    port: int = typer.Argument(..., help="Service port number.", show_default=False),
    detail: str = typer.Option(
        "Service", "--detail", "-d", help="Meaningful description for backoff port"
    ),
) -> None:
    """Wait until dependent service is ready."""
    makester.waitster.port_backoff(host, port, detail)


@app.callback()
def common(
    ctx: typer.Context,
    quiet: bool = typer.Option(
        False, "--quiet", help='Disable logs to screen (to log level "ERROR")'
    ),
) -> None:
    """Define the common arguments."""
    ctx.obj = Common(quiet)

    if ctx.obj.quiet:
        suppress_logging()
