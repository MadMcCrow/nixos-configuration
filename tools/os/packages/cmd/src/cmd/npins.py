#! /usr/bin/env python3
# need nix package "npins"

from asyncio import sleep
from os import getenv
from pathlib import Path
from shlex import split

# uv
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]

# provided by us
from tui import Progress
from cmd.awaitable import Awaitable
from cmd.exceptions import ShellException, assert_cmd

NIXPKGS_TAG = getenv("NIXPKGS_TAG")


class _npins:
    def __init__(self, dir: Path | str = "", display: bool = True) -> None:
        """initialize our npins accessor"""
        assert_cmd("npins")
        # ensure directory exists
        self._dir = Path(dir).resolve()
        self._dir.parent.mkdir(parents=True, exist_ok=True)
        self._cmd = sh(["npins", "-d", self._dir])
        self._display = display

    async def _run(self, args, desc: str = ""):
        """Run a subcommand while showing a spinner."""
        cmd = self._cmd(args)
        if self._display:
            async with Progress(desc) as progress:
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


class npins_init(_npins, Awaitable):
    async def _exec(self):
        """Wrap `npins -d <directory> init`."""
        if NIXPKGS_TAG is not None:
            await self._run(["init", "--bare"], f"Initializing npins directory {self._dir}")
            await self._run(
                split("add github nixos nixpkgs --at <commit-hash> --name nixpkgs"),
                f"Pinning nixpkgs to install version {self._dir}",
            )
        else:
            await self._run("init", f"Initializing npins sources in {self._dir}")


class npins_update(_npins, Awaitable):
    async def _exec(self):
        """Wrap `npins -d <directory> update`."""
        return await self._run("update", f"Updating npins sources in {self._dir}")
