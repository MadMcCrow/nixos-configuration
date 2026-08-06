# python
from asyncio import TaskGroup

from init.steps import GenerateHardwareConfig, CopyTemplate
from shared import Awaitable, Config
from shared.cmd import nixformat

# TODO : add hostname auto fix
# TODO : add open editor
async def init_config(dir: str | None, edit: bool, quiet: bool = False):
    """
    perform the installation process
    """
    c = Config(dir)
    async def wrap_coro(awaitable: Awaitable):
        return await awaitable

    # run concurrenlty :
    async with TaskGroup() as tg:
        tg.create_task(wrap_coro(GenerateHardwareConfig(c["hardware-configuration.nix"], not quiet)))
        tg.create_task(wrap_coro(CopyTemplate(c.dir, not quiet)))

    nixfiles = c.dir.rglob('*.nix')
    await nixformat(*nixfiles, description="formatting nixfiles", display=not quiet)
