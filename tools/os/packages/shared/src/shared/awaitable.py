# awaitable.py
# helper for building classes that can be awaited
from asyncio import Task

class Awaitable(Task):
    """ helps with writing async classes """
    async def _exec(self):
        raise NotImplementedError("you must implement _exec")

    def __await__(self):
        return self._exec().__await__()
