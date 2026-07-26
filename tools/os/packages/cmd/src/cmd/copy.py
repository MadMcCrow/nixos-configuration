from asyncio import TaskGroup
from pathlib import Path

from cmd.awaitable import Awaitable
from aiofiles import open
from tui import Progress

type Operation = tuple[Path | str, Path | str]


async def _copy_file(source_file, target_file):
    """coroutine to copy a file"""
    async with open(source_file, "rb") as source, open(target_file, "wb") as target:
        await target.write(await source.read())


class cp(Awaitable):
    """
    batch copy files in a single command
    """

    def __init__(
        self,
        *ops: Operation,
        file_exists_ok: bool = False,
        display: bool = True,
        description: str = "copying files",
    ):
        """build a list of copy to make"""
        self._ops = [([Path(x), Path(y)]) for (x, y) in ops]
        # verify
        for op in self._ops:
            # source must exist
            if not op[0].exists():
                raise FileNotFoundError(op[0])
            if not file_exists_ok and op[1].exists():
                raise FileExistsError(op[1])
        self._display = display
        self._desc = description

    async def _exec(self):
        """batch copy"""
        async with TaskGroup() as tg:
            if self._display:
                async with Progress(self._desc) as progress:

                    async def progress_copy(x, y):
                        with progress.info(f"{x} -> {y}"):
                            await _copy_file(x, y)

                    for op in self._ops:
                        tg.create_task(progress_copy(op[0], op[1]))
            else:
                for op in self._ops:
                    tg.create_task(_copy_file(op[0], op[1]))
