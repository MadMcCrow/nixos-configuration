#!/usr/bin/env python
# output / logging support

from asyncio import StreamReader, TaskGroup, subprocess
from locale import getencoding
from typing import Callable, TypeAlias

# output callback type alias
Callback: TypeAlias = Callable[[str, bool], float | None]


class Output(object):
    """
    support class to write output and log.
    this is not exposed to the user, but it implements the methods
    used in the class Pycall
    """

    def __init__(self, cbs: list[Callback] = []):
        self.out: str = ""
        self.err: str = ""
        self._cbs: list[Callback] = cbs
        self._prg: float | None = None
        self._rc: int | None = None

    async def parse_stdio(self, ps: subprocess.Process):
        debug(f"starting output object for process {ps}")
        async with TaskGroup() as stdio_tasks:
            _ = stdio_tasks.create_task(self._read_stream(ps.stdout, False))
            _ = stdio_tasks.create_task(self._read_stream(ps.stderr, True))
        self._rc = ps.returncode

    async def _read_stream(
        self, stream: StreamReader | None, err: bool = False
    ) -> None:
        """
        helper method to parse stdout and stderr the same way
        """
        while True:
            if not stream:
                break

            line = await stream.readline()
            if line:
                txt: str = line.decode(getencoding())
                if err:
                    self.err += f"\n{txt}"
                else:
                    self.out += f"\n{txt}"
                for cb in self._cbs:
                    try:
                        res = cb(txt, err)
                        if isinstance(res, float):
                            self._prg = res
                    except Exception as E:
                        error(f"{type(E)} : failed to call {cb} : {E}")
                        continue  # ignore problem
            else:
                break

    def cancel(self):
        pass

    def progress(self) -> float | None:
        return self._prg

    def return_code(self) -> int | None:
        return self._rc
