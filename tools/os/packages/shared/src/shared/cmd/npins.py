#! /usr/bin/env python3
# need nix package "npins"

# python
from asyncio import sleep
from pathlib import Path

# uv
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]

#ours
from shared.awaitable import Awaitable
from shared.exceptions import ShellException, assert_cmd
from shared.tui import Progress

class npins(Awaitable):
    def __init__(self, args, *, dir: Path | str = "", description : str = "", display: bool = True) -> None:
        """ initialize our npins accessor """
        assert_cmd("npins")
        # ensure directory exists
        self._dir = Path(dir).resolve()
        self._dir.parent.mkdir(parents=True, exist_ok=True)
        self._cmd = sh(["npins", "-d", self._dir])
        self._desc = description
        self._display = display
        self._args = args

    async def _exec(self):
        """ Run a subcommand while showing a spinner. """
        cmd = self._cmd(self._args)
        if self._display:
            async with Progress(self._desc) as progress:
                try:
                    async for line in cmd.stderr(sh.STDOUT):
                        with progress.info("") as info:
                            if line.startswith("Err"):
                                pass
                            elif line.startswith("[INFO"):
                                info.update(line.split("]", 1)[-1].strip())
                            elif line.startswith("[WARN"):
                                info.update(f"Warning :{line.split(']', 1)[-1].strip()}")
                            await sleep(0)
                except ResultError as exc:
                    raise ShellException(cmd, exc)
        else:
            await cmd()
