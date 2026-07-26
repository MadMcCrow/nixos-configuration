#!/usr/bin/env python3

# python
from asyncio import TaskGroup, sleep
from os import getenv
from pathlib import Path

# commands
from commands.awaitable import Awaitable
from commands.copy import Copy
from commands.nixos_generate_config import nixos_generate_config
from commands.npins import npins_init
from commands.progress import Progress
from commands.text_edit import Editor

# ours
from ostool.config import Config


class _os_init_config(Awaitable):
    def __init__(self, file: Path | str, edit: bool = False, display: bool = True) -> None:
        """Copy template and let user edit content"""
        self._file = Path(file)
        self._display = ""
        self._edit = edit

    async def _exec(self):
        """copy template and edit config"""

        async def _copy():
            template = getenv("TEMPLATE_CONFIG") or ""
            assert template != "", "template config not found"
            await Copy((template, self._file))

        async def _edit():
            await Editor(self._file)

        steps = []
        if not self._file.exists():
            steps += ("copy template", _copy)
        if self._edit:
            steps += ("edit config", _edit)

        if self._display:
            async with Progress("Writing machine config") as progress:
                for step in steps:
                    with progress.info(step[0]):
                        await step[1]()
                        await sleep(0.1)
        else:
            for step in steps:
                await step[1]()


async def init(hostname: str):
    """
    perform the installation process
    """
    configs = Config(Path("./.test/")).config_files()

    # prepare our async objects for making the config
    ed = _os_init_config(configs["configuration.nix"])
    hc = nixos_generate_config(configs["hardware-configuration.nix"])
    np = npins_init(configs["npins"])

    # private wrapper to have it in the form of a coro
    async def _wrap_coro(aw):
        return await aw

    # run concurrenlty :
    async with TaskGroup() as tg:
        tg.create_task(_wrap_coro(ed))
        tg.create_task(_wrap_coro(hc))
        tg.create_task(_wrap_coro(np))
