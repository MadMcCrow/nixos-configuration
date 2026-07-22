from asyncio import Task

class Awaitable(Task) :
    async def _exec(self) :
        raise NotImplementedError("you must implement _exec")

    def __await__(self) :
        return self._exec().__await__()