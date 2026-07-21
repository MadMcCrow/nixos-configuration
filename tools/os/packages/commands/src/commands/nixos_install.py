# need nix package "nixos-install-tools" and "nixos-install"

from pathlib import Path

# provided by uv
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]
from aiofiles import open # pyright: ignore [reportMissingImports]

# ours
from commands.progress import Progress
from commands.exceptions import ShellException, assert_cmd

class nixos_install() :
    async def execute(self, display :bool = True) :
        """ run the generate config and write the file to target directory """
        hardwareconfig = ""
        if display :
            async with Progress("installing nixos") as progress:
                with progress.info("generating config") :
                    pass