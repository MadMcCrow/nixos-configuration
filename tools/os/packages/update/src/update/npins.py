
from shared import Awaitable, Config
from shared.cmd.npins import npins


class npins_update(Awaitable):

    def __init__(self) :
        self._config = Config()
        self._dir = self._config["npins"]

    async def _exec(self):
        """Wrap `npins -d <directory> update`."""
        return await npins("update", dir = self._dir, description="Updating npins sources")
