
from os import getenv
from pathlib import Path
from shlex import split
from shared import Awaitable
from shared.cmd.npins import npins

NIXPKGS_TAG = getenv("NIXPKGS_TAG", None)
NIXPKGS_BRANCH = getenv("NIXPKGS_BRANCH", None)

class InitNpins(Awaitable):

    def __init__(self, dir : Path, display: bool = True) :
        self._dir = dir
        self._display = display;

    async def _exec(self):
        """Wrap `npins -d <directory> init`."""
        if NIXPKGS_TAG is not None and NIXPKGS_BRANCH is not None :
            await npins(["init", "--bare"],
                dir = self._dir,
                description="Initializing npins directory",
                display=self._display)
            await npins(split(f"add github nixos nixpkgs --at {NIXPKGS_TAG} --branch {NIXPKGS_BRANCH} --name nixpkgs"),
                 dir = self._dir,
                 description="Pinning nixpkgs to install version",   display=self._display)
        else:
            await npins(["init"], dir = self._dir, description="Initializing npins directory", display=self._display)