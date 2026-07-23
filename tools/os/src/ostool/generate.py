#!/usr/bin/env python3
#
from asyncio import TaskGroup
from pathlib import Path
# commands
from commands.npins import npins_init, npins_update
from commands.nixos_generate_config import nixos_generate_config
from commands.os_edit_config import os_edit_config


async def generate(args) :
    """
    perform the installation process
    """
    assert (args.hostname is not None), "no hostname provided !"
    config_dir = Path("./.test/")

    # prepare our async objects for making the config
    ed = os_edit_config(config_dir.joinpath("configuration.nix"))
    hc = nixos_generate_config(config_dir.joinpath("hardware-configuration.nix"))
    np = npins_init(config_dir.joinpath("npins"))


    # private wrapper to have it in the form of a coro
    async def _wrap_coro(aw) :
        return await aw

    # run concurrenlty :
    async with TaskGroup() as tg :
        tg.create_task(_wrap_coro(ed))
        tg.create_task(_wrap_coro(hc))
        tg.create_task(_wrap_coro(np))


    # now build



