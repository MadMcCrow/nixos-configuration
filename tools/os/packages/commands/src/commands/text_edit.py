# python
from typing import TypeAlias

# uv
from aiofiles import open
from prompt_toolkit.application import Application
from prompt_toolkit.layout import Layout, Window, HSplit
from prompt_toolkit.styles import Style
from prompt_toolkit.widgets import TextArea
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.layout.controls import FormattedTextControl

# ours
from commands.awaitable import Awaitable
from commands.progress import Context

optstr : TypeAlias = str | None

class Editor(Awaitable) :
    """ nice looking text editor that runs async """

    def __init__(self, file, *,content : optstr = None , top_comment : optstr = None ) :
        """ store info for async creation """
        self._file = file
        self._content = content
        self._top_comment = top_comment
        self._editor : TextArea | None = None


    async def _make_app(self) :
        """
            spawns a nice-enough editor to edit the configuration
        """
        if not self._content :
            async with open(self._file, "r") as f:
                self._content  = await f.read()

        self._editor = TextArea(text=self._content, scrollbar = True, line_numbers = True)
        kb = KeyBindings()


        bottom_bar = Window(
            height=1,
            content=FormattedTextControl("Press Ctrl-S to save and Ctrl-X to save and exit."),
            style="class:bottom")

        @kb.add("c-s")
        async def save(event):
            await self._save()

        @kb.add("c-x")
        async def quit(event): #pyright: ignore [reportUnusedFunction]
             await self._save()
             event.app.exit()

        if self._top_comment :
            top_bar = Window(height=1, content=FormattedTextControl(self._top_comment, style="class:top"))
            layout =Layout(HSplit([top_bar, self._editor, bottom_bar,]))
        else :
            layout = Layout(HSplit([self._editor,bottom_bar,]))

        editor_style = Style([
             ("top", "bold fg:#ffffff" ),
             ("bottom", "fg:lightgrey" ),
         ])
        return Application(
                layout=layout,
                key_bindings=kb,
                full_screen=True,
                style=editor_style
            )

    async def _exec(self) :
        """
            open an editor for the user
        """
        Context().pause()
        await (await self._make_app()).run_async()
        Context().unpause()

    async def _save(self) :
        """ saves the content of the text editor """
        if self._editor :
            async with open(self._file, "w") as f:
                await f.write(self._editor.text)

