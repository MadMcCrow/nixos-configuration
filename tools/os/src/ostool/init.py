#!/usr/bin/env python3

# python
from asyncio import TaskGroup
from pathlib import Path

from commands.nixos_generate_config import nixos_generate_config

# commands
from commands.npins import npins_init

# ours
from ostool.config import Config


async def generate(hostname: str):
    """
    perform the installation process
    """
    configs = Config(Path("./.test/")).config_files()

    # prepare our async objects for making the config
    ed = os_edit_config(configs["configuration.nix"])
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
