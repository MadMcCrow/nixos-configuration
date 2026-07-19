#! /usr/bin/env python3

# provided by uv
from rich.console import Console # pyright: ignore [reportMissingImports]
from rich.progress import Progress, SpinnerColumn, TextColumn # pyright: ignore [reportMissingImports]
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]

_console = Console()

async def run(*args: str, description: str) -> str | None:
    """Run an `npins` subcommand while showing a spinner."""
    cmd = sh("npins", *args)
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=_console,
        transient=True,  # spinner disappears once done
    ) as progress:
        progress.add_task(description, total=None)
        try:
            return await cmd
        except ResultError as exc:
            _console.print(f"[red]npins {' '.join(args)} failed:[/red] {exc}")
            return None
