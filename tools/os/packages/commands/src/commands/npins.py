#! /usr/bin/env python3
# need nix package "npins"

from ast import Await
from asyncio import sleep
from pathlib import Path

# provided by uv
from commands.awaitable import Awaitable
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]

# ours
from commands.progress import Progress
from commands.exceptions import ShellException, assert_cmd



# pin to a nixpkgs commit : npins add github NixOS nixpkgs --branch nixos-unstable --at <commit-sha-or-tag> --name nixpkgs

class _npins() :
    def __init__(self, dir: Path | str = "") -> None :
        """ initialize our npins accessor """
        assert_cmd("npins")
        # ensure directory exists
        self.dir = Path(dir).resolve()
        self.dir.parent.mkdir(parents=True, exist_ok=True)
        self.cmd = sh([
        "npins",
        "-d",
        self.dir
        ])


    async def _run(self, args, desc : str = "") :
        """Run a subcommand while showing a spinner."""
        cmd = self.cmd(args)
        async with Progress(desc) as progress:
            try:
                async for line in cmd.stderr(sh.STDOUT) :
                    with progress.info("") as info :
                        if line.startswith('Err') :
                            pass
                        elif line.startswith('[INFO') :
                            info.update(line.split("]", 1)[-1].strip())
                        elif line.startswith('[WARN') :
                             info.update(f"Warning :{line.split("]", 1)[-1].strip()}")
                        await sleep(0)
            except ResultError as exc:
                raise ShellException(cmd, exc)

class npins_init(_npins, Awaitable) :
    async def exec(self):
         """Wrap `npins -d <directory> init`."""
         return await self._run("init", f"Initializing npins sources in {self.dir}")


class npins_update(_npins, Awaitable) :
    async def exec(self):
        """Wrap `npins -d <directory> update`."""
        return await self._run("update", f"Updating npins sources in {self.dir}")
