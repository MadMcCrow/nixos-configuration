from aiofiles import open
from cmd.awaitable import Awaitable
from tui import Editor

type OptStr = str | None

class textedit(Awaitable):
    """nice looking text editor that runs async"""

    def __init__(self, file, *, top_comment: OptStr = None):
        """store info for async creation"""
        self._file = file
        self._top_comment = top_comment

    async def _exec(self):
        """
        open an editor for the user
        """
        init_text = ""
        async with open(self._file, "r") as f:
            init_text = await f.read()
        async def on_save(text : str) :
            async with open(self._file, "w") as f:
               await f.write(text)
        editor = Editor(init_text, on_save=on_save, on_quit=on_save, top_comment=self._top_comment)
        await editor.edit()