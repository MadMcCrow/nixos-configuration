#!/usr/bin/env python
# Class to have async calls to programs
# The Core of pycall


# asyncio deps
from asyncio import Task, TaskGroup, create_task, subprocess
from shutil import which

# our simple log !
from slog import info

# ours
from .output import Callback, Output


class Pycall(object):
    """
    Class for making exec calls asynchronously
    we do not run in a shell, but the process is executed
    in a separate thread.

    you do not need to interact directly with this class,
    instead use the pycall functions
    """

    __cmd: str = ""
    __out: Output | None = None
    __args: list[str] = []
    __task: Task | None = None

    @classmethod
    async def call(cls, cmd: str, args: list[str], *cbs: Callback):
        """
        create an run Pycall process.

        """
        self: Pycall = cls()
        self.__private_init(cmd, args, list(*cbs))
        self.__task = create_task(self.__process())
        await self.__task
        return self

    async def __process(self) -> None:
        """
        run the actual process, along with a throbber,
        an output object and some parsing tasks
        """
        shellcmd = " ".join([self.__cmd] + self.__args)
        info(f"calling '{shellcmd}' ")
        ps = await subprocess.create_subprocess_shell(
            shellcmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        async with TaskGroup() as tg:
            _ = tg.create_task(ps.wait())
            _ = tg.create_task(self.__out.parse_stdio(ps))

    def __await__(self):
        return self.__task.__await__()

    def __private_init(self, cmd: str, args: list[str], cbs: list[Callback]) -> None:
        """
        initialize this Pycall object with what's
        """
        if which(cmd) is None:
            raise RuntimeError(f"{cmd} : command not found")
        self.__cmd = cmd
        self.__out = Output(cbs)
        # TODO : perform checks on args :
        self.__args = args

    def rc(self):
        return self.__out.return_code()

    def stdout(self) -> str:
        return self.__out.out

    def stderr(self) -> str:
        return self.__out.err
