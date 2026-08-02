# context.py
# Context for showing or hiding progress
from shared.singleton import SingletonMeta
from rich.console import Console, Group, RenderableType
from rich.live import Live

class Context(metaclass=SingletonMeta):
    def __init__(self):
        self._console: Console = Console()
        self._renderable: dict[object, RenderableType] = {}
        self._active: set[object] = set()
        self._live = Live(
            None,
            console=self._console,
            refresh_per_second=25,
            transient=False,
        )
        self._paused = False

    def refresh(self):
        """build the display"""
        group = Group(*self._renderable.values())
        if not self._paused:
            if not self._live._started:
                self._live.start()
            self._live.update(group)

    def update(self, owner: object, renderable: RenderableType):
        """activate owner, group our renderables, and update display"""
        self._active.add(owner)
        self._renderable[owner] = renderable
        self.refresh()

    def stop(self, owner):
        "deactivate owner and stop display if necessary"
        if owner in self._active:
            self._active.remove(owner)
        if len(self._active) == 0 and self._live.is_started:
            self._live.stop()

    def pause(self):
        self._paused = True
        self._live.stop()

    def unpause(self):
        self._paused = False
        self._live.start()
        self.refresh()
