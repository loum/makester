"""makefiles CLI.

"""
import typer


app = typer.Typer(add_completion=False, help="CLI tool")


@app.command()


def main() -> None:
    """Script entry point."""
    app()


if __name__ == "__main__":
    main()
