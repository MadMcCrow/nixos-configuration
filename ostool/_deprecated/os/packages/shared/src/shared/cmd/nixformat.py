#! /usr/bin/env python3

# python
from asyncio import run
from pathlib import Path
from sys import argv

# ours
from shared.awaitable import Awaitable

# uv
from shared.tui import Progress
from shellous import ResultError, sh  # pyright: ignore [reportMissingImports]


class nixformat(Awaitable):
    """
    class to help format nix files in a clean way :
        - removes unecessary empty lines
        - removes unused arguments
        - applies a strict formatting
    """

    def __init__(self, *files: str | Path, description: str = "", display: bool = True):
        self._files = [Path(file).absolute() for file in files]
        self._errors = []
        self._display = display
        self._desc = description

    async def _exec(self):
        fixups = [
            lambda f: ["deadnix", "-eq", str(f)],
            lambda f: ["alejandra", "-q", str(f)],
            lambda f: ["nixfmt", "-sq", str(f)],
        ]

        async def fixup(fmt):
            try:
                await sh(fmt)
            except ResultError as exc:
                # ignore formatter errors
                self._errors.append(exc)

        if self._display:
            async with Progress(description=self._desc) as p:
                for fl in self._files:
                    for fn in fixups:
                        with p.info(f"formatting {fl} with {fn(fl)[0]}"):
                            await fixup(fn(fl))
        else:
            for fl in self._files:
                for fn in fixups:
                    await fixup(fn(fl))


async def main():
    await nixformat(argv[1])


if __name__ == "__main__":
    run(main())
