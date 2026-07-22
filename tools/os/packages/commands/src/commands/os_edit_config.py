# need nix package "nixos-install-tools" and "nixos-install"

# provided by python
from asyncio import sleep
from os import getenv
from pathlib import Path
from sys import argv
from typing import Awaitable

# provided by uv
from shellous import sh  # pyright: ignore [reportMissingImports]
from aiofiles import open # pyright: ignore [reportMissingImports]
from prompt_toolkit.application import Application # pyright: ignore [reportMissingImports]
from prompt_toolkit.layout import Layout # pyright: ignore [reportMissingImports]
from prompt_toolkit.widgets import TextArea # pyright: ignore [reportMissingImports]

# provided by us
from commands.progress import Progress

APPNAME = argv[0]

TEMPLATE_CONFIG=getenv("TEMPLATE_CONFIG") or ""
assert TEMPLATE_CONFIG is not None, "template config not found"

class os_edit_config(Awaitable) :

    def __init__(self, file: Path | str = "", display :bool = True) -> None :
        """ Copy template and let user edit content """
        self.file = Path(file).resolve()
        self.file.parent.mkdir(parents=True, exist_ok=True)
        self._display = display

    async def _exec(self) :
        async def _copy() :
             """ copy the config from the template """
             async with open(TEMPLATE_CONFIG, "r") as source :
                 async with open(self.file, "w") as target :
                     await target.write(await source.read())

        async def _edit() :
            """ copy the config from the template """
            EDITOR = getenv("EDITOR", getenv("VISUAL"))
            if EDITOR is not None :
                await sh([EDITOR, self.file]).pty()
            else :
                text = ""
                async with open(self.file, "r") as config :
                    text = await config.read()
                editor = TextArea(text=text, scrollbar = True, line_numbers = True)
                app = Application(layout = Layout(editor), full_screen = True)
                await app.run_async()

        steps = [
            ("copy template", _copy),
            ("edit config", _edit)
        ]

        if self._display :
            async with Progress("Writing machine config") as progress:
                for step in steps :
                    with progress.info(step[0]) :
                        await step[1]()
                        await sleep(0.1)
        else :
            for step in steps :
                await step[1]()