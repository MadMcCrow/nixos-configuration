# python
import shutil
from asyncio import to_thread
from os import getenv
from pathlib import Path

# ours
from shared import Awaitable, Config
from shared.tui import Progress


class CopyTemplate(Awaitable):
    """copy the configuration template"""

    def __init__(self, dir, display: bool = True):
        template = getenv("OS_TEMPLATE")
        if not template:
            raise RuntimeError("`OS_TEMPLATE` environment variable not found")
        self._source = Path(template)
        if not self._source.exists():
            raise FileNotFoundError(f"{self._source} does not exist.")
        self._target = Config(dir).dir
        self._display = display

    def _copy(self):
        for p in self._source.rglob("*", recurse_symlinks=True):
            try:
                target = self._target / p.relative_to(self._source)

                if p.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    if target.exists():
                        target.unlink()
                    shutil.copy2(p, target)

            except PermissionError as e:
                print("Permission error:")
                print("errno:", e.errno)
                print("filename:", e.filename)
                print("filename2:", getattr(e, "filename2", None))
                raise

    async def _exec(self):
        """Copy the template config"""

        if self._display:
            async with Progress("copying host configuration template"):
                await to_thread(self._copy)
        else:
            await to_thread(self._copy)
