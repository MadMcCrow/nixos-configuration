# python
from asyncio import TaskGroup
from shared import Awaitable, Config
from init.steps import GenerateHardwareConfig, GenerateHostConfig, InitNpins

async def init_config(dir: str | None, hostname: str|None, edit: bool, quiet: bool = False):
    """
    perform the installation process
    """
    c = Config(dir)

    coros : list[Awaitable]= [
        GenerateHardwareConfig(c["hardware-configuration.nix"], not quiet),
        GenerateHostConfig(c.dir, hostname, not quiet),
        InitNpins(c["npins"], not quiet)
    ]

    async def wrap_coro( awaitable : Awaitable):
        return await awaitable

    # run concurrenlty :
    async with TaskGroup() as tg:
        for f in coros :
            tg.create_task(wrap_coro(f))



