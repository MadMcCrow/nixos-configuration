# python
from os import getenv
from re import sub
# uv
from aiofiles import open
#ours
from shared import Awaitable
from shared import Config
from shared.cmd.nixformat import nixformat
from shared.tui import Progress

TEMPLATE = getenv("TEMPLATE_CONFIG") or ""
assert TEMPLATE != "", "template config not found"

_pattern = r'(?<=[A-Za-z0-9_.-]+\.hostname\s*=\s*")[^"]*(?=";)'

class GenerateHostConfig(Awaitable):
    """ copy the configuration template """

    def __init__(self, dir, hostname : str |None = None, display : bool = True):
        c = Config(dir)
        self.target = c["configuration.nix"]
        self.display = display
        self.hostname = hostname

    async def _exec(self) :
        """ generate a config for the host """

        async def copyinplace() :
            async with open(TEMPLATE, "r") as temp,  open(self.target, "w") as target :
                async for line in temp :
                    if self.hostname is not None :
                        line = sub(_pattern, self.hostname, line)
                    await target.write(f"{line.strip()}/n")
        async def format():
            await nixformat(self.target)

        steps = []
        if not self.target.exists():
            steps.append((copyinplace, "init template"))
        steps.append((format, "format nix configuration"))

        if self.display :
            async with Progress("generating host configuration") as progress :
                for step, description in steps :
                    with progress.info(description) :
                        await step()
        else :
            for step, _ in steps :
                    await step()





