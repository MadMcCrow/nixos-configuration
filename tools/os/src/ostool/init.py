#!/usr/bin/env python3

# python
from asyncio import TaskGroup

# commands
from cmd.copy import cp
from cmd.edit import textedit
from cmd.nixos_generate_config import nixos_generate_config
from cmd.npins import npins_init
from fileinput import input
from os import getenv
from re import sub

# ours
from ostool.config import Config


async def init(config: str | None, hostname: str, edit: bool, quiet: bool = False, **xargs):
    """
    perform the installation process
    """
    c = Config(config)

    async def copy_template():
        target = c["configuration.nix"]
        if target.exists():
            return
        else:
            template = getenv("TEMPLATE_CONFIG") or ""
            assert template != "", "template config not found"
            await cp(
                (template, target),
                file_exists_ok=False,  # file must not exist !
                display=not quiet,
                description="copying template",
            )

    # prepare our async objects for making the config
    hc = nixos_generate_config(c["hardware-configuration.nix"], not quiet)
    np = npins_init(c["npins"], not quiet)

    async def _wrap_coro(aw):
        return await aw

    # run concurrenlty :
    async with TaskGroup() as tg:
        tg.create_task(copy_template())
        tg.create_task(_wrap_coro(hc))
        tg.create_task(_wrap_coro(np))

    if hostname is not None:
        # replace the hostname for the user
        pattern = r'(?<=[A-Za-z0-9_.-]+\.hostname\s*=\s*")[^"]*(?=";)'
        with input(c["configuration.nix"], inplace=True) as f:
            for line in f:
                line = sub(pattern, hostname, line)

    if edit:
        await textedit(c["configuration.nix"])
