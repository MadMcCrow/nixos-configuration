# context.py
# Context for showing or hiding progress
from atexit import register

from rich.console import Console, Group, RenderableType
from rich.live import Live
from shared.singleton import SingletonMeta


class Context(metaclass=SingletonMeta):
    def __init__(self):
        self._console: Console = Console()
        self._renderable: dict[object, RenderableType] = {}
        self._live = Live(
            None,
            console=self._console,
            refresh_per_second=25,
            transient=True,
        )
        self._paused = False
        register(self.close)  # register with atexit

    def _ensure_started(self):
        if not self._paused and not self._live.is_started:
            self._live.start()

    def refresh(self):
        """rebuild the live area from currently *active* renderables only"""
        self._ensure_started()
        if not self._paused:
            self._live.update(Group(*self._renderable.values()))

    def update(self, owner: object, renderable: RenderableType):
        """update an in-progress owner's renderable (spinner overwrites itself)"""
        self._renderable[owner] = renderable
        self.refresh()

    def finish(self, owner: object, renderable: RenderableType):
        """
        finalize owner: print its final state permanently (above the live
        area) and drop it from the live-updating set, so it's never
        redrawn/duplicated.
        """
        self._renderable.pop(owner, None)
        self._ensure_started()
        self._console.print(renderable)  # Rich handles this above the live region
        self.refresh()

    def pause(self):
        self._paused = True
        if self._live.is_started:
            self._live.stop()

    def unpause(self):
        self._paused = False
        self.refresh()

    def close(self):
        """call once at real program exit, or before handing off the
        terminal entirely (e.g. to Editor)."""
        if self._live.is_started:
            self._live.stop()
        self._renderable.clear()
