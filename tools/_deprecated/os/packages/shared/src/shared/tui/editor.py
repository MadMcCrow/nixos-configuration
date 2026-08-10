from collections.abc import Callable

from prompt_toolkit.application import Application
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.layout import HSplit, Layout, Window
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.styles import Style
from prompt_toolkit.widgets import TextArea
from shared.tui.context import Context

type Coro = Callable | None


class Editor:
    """nice looking text editor that runs async"""

    def __init__(
        self,
        content: str = "",
        on_save: Coro = None,
        on_quit: Coro = None,
        top_comment: str | None = None,
    ):
        """store info for async creation"""
        self._content = content
        self._top_comment = top_comment
        self._on_quit = on_quit
        self._on_save = on_save

    async def _make_app(self):
        """
        spawns a nice-enough editor to edit the configuration
        """

        editor = TextArea(text=self._content, scrollbar=True, line_numbers=True)
        kb = KeyBindings()

        bottom_bar = Window(
            height=1,
            content=FormattedTextControl("Press Ctrl-S to save and Ctrl-X to save and exit."),
            style="class:bottom",
        )

        @kb.add("c-s")
        async def save(event):  # pyright: ignore [reportUnusedFunction]
            if self._on_save is not None:
                await self._on_save(editor.text)

        @kb.add("c-x")
        async def quit(event):  # pyright: ignore [reportUnusedFunction]
            if self._on_quit is not None:
                await self._on_quit(editor.text)
            event.app.exit()

        if self._top_comment:
            top_bar = Window(
                height=1, content=FormattedTextControl(self._top_comment, style="class:top")
            )
            layout = Layout(
                HSplit(
                    [
                        top_bar,
                        editor,
                        bottom_bar,
                    ]
                )
            )
        else:
            layout = Layout(
                HSplit(
                    [
                        editor,
                        bottom_bar,
                    ]
                )
            )

        editor_style = Style(
            [
                ("top", "bold fg:#ffffff"),
                ("bottom", "fg:lightgrey"),
            ]
        )
        return Application(layout=layout, key_bindings=kb, full_screen=True, style=editor_style)

    async def edit(self):
        """open an editor for the user"""
        Context().pause()
        app = await self._make_app()
        await app.run_async()
        Context().unpause()

    async def __await__(self):
        return self.edit().__await__()
