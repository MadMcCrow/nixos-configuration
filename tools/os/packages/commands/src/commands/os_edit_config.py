# need nix package "nixos-install-tools" and "nixos-install"

# python
from asyncio import sleep
from os import getenv
from pathlib import Path
from sys import argv

from aiofiles import open
from commands.awaitable import Awaitable
from commands.progress import Context, Progress

# ours
from commands.text_edit import Editor

# uv
from shellous import sh

APPNAME = argv[0]

TEMPLATE_CONFIG = getenv("TEMPLATE_CONFIG") or ""
assert TEMPLATE_CONFIG is not None, "template config not found"


class os_edit_config(Awaitable):
    def __init__(self, file: Path | str = "", display: bool = True) -> None:
        """Copy template and let user edit content"""
        self.file = Path(file).resolve()
        self.file.parent.mkdir(parents=True, exist_ok=True)
        self._display = display

    async def _exec(self):
        """copy the template and open an editor for the user"""

        async def _copy():
            """copy the config from the template"""
            # skip if file already exists
            if self.file.exists():
                return
            async with open(TEMPLATE_CONFIG, "r") as source:
                async with open(self.file, "w") as target:
                    await target.write(await source.read())

        async def _edit():
            """copy the config from the template"""
            EDITOR = getenv("EDITOR", getenv("VISUAL"))
            if EDITOR:
                Context().pause()
                await sh([EDITOR, self.file]).pty()
                Context().unpause()
            else:
                await Editor(self.file, top_comment="edit machine configuration :")

        steps = [("copy template", _copy), ("edit config", _edit)]

        if self._display:
            async with Progress("Writing machine config") as progress:
                for step in steps:
                    with progress.info(step[0]):
                        await step[1]()
                        await sleep(0.1)
        else:
            for step in steps:
                await step[1]()
