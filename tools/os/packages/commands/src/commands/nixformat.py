#! /usr/bin/env python3

# python
from asyncio import run
from pathlib import Path
from sys import argv

# uv
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]

# ours
from commands.awaitable import Awaitable

class nixformat(Awaitable):
    """
    class to help format nix files in a clean way :
        - removes unecessary empty lines
        - removes unused arguments
        - applies a strict formatting
    """
    def __init__(self, file : Path|str) :
        self.file = Path(file).absolute()

    async def _exec(self) :
        fixups = [
            ["deadnix","-eq", f'{self.file}'],
            ["alejandra","-q", f'{self.file}'],
            ["nixfmt","-sq", f'{self.file}']
        ]
        for f in fixups :
            try :
                await sh(f)
            except ResultError as exc:
                print(exc)
                pass # ignore formatter errors

async def main() :
    await nixformat(argv[1])

if __name__ == "__main__":
    run(main())

