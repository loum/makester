"""makefiles CLI.

"""
import typer

from .logging_config import log


app = typer.Typer(add_completion=False, help="CLI tool")


@app.command()
def supa_idea() -> None:
    """Command placeholder."""
    log.info("Looks like you invoked the supa_idea command 🤓")
