#! /usr/bin/env python3

from pathlib import Path
from npins.shell import run

# exposed methods
__all__ = ["init", "update"]

async def init(directory: Path) -> str | None:
    """Wrap `npins -d <directory> init`."""
    return await run(
        "-d", str(directory), "init",
        description=f"Initializing npins in {directory}…",
    )

async def update(directory: Path) -> str | None:
    """Wrap `npins -d <directory> update`."""
    return await run(
        "-d", str(directory), "update",
        description=f"Updating npins sources in {directory}…",
    )
