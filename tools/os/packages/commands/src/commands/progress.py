#! /usr/bin/env python3

# python deps
from asyncio import create_task, run, sleep
from threading import Lock
from typing import Any, ClassVar, Dict, List, Set

# rich deps
from rich.console import Console, Group, RenderableType
from rich.live import Live
from rich.spinner import Spinner
from rich.text import Text


class _SingletonMeta(type):
    _lock : ClassVar[Lock] = Lock()
    _instances = {}
    def __call__(cls, *args: Any, **kwds: Any):
        with cls._lock :
            if cls not in cls._instances:
                instance = super().__call__(*args, **kwds)
                cls._instances[cls] = instance
        return cls._instances[cls]



class Context(metaclass=_SingletonMeta) :

    def __init__(self) :
        self._console : Console = Console()
        self._renderable : Dict[object, RenderableType] = {}
        self._active : Set[object] = set()
        self._live = Live(
            None,
            console=self._console,
            refresh_per_second=25,
            transient=False,
        )
        self._paused = False

    def refresh(self):
        """ build the display """
        group = Group(*self._renderable.values())
        if not self._paused :
            if not self._live._started :
                self._live.start()
            self._live.update(group)

    def update(self, owner : object, renderable : RenderableType):
        """ activate owner, group our renderables, and update display """
        self._active.add(owner)
        self._renderable[owner] = renderable
        self.refresh()

    def stop(self, owner) :
        "deactivate owner and stop display if necessary"
        if owner in self._active :
            self._active.remove(owner)
        if len(self._active) == 0  and  self._live.is_started :
            self._live.stop()

    def pause(self) :
        self._paused = True
        self._live.stop()

    def unpause(self) :
        self._paused = False
        self._live.start()
        self.refresh()


class _Info:
    """
    class for describing a subline in our progress TUI
    """

    def __init__(self, parent : Progress, message : str, duration : float|None) :
        self._parent = parent
        self._message = message
        if duration:
            async def cancel_coro() :
                await sleep(duration)
                self.remove()
            self._remove_task = create_task(cancel_coro())
        else :
            self._remove_task = None

    def remove(self)-> None :
        if self._parent :
            self._parent.clear_info(self)

    def update(self, message) :
        self._message = message

    def __str__(self) -> str:
        return self._message

    def __enter__(self) -> "_Info":
        return self # no need to do anything, just exist !

    def __exit__(self, exc_type, exc_val, exc_tb) -> bool:
        self._parent.clear_info(self)
        return False




class Progress:
    """
    A Rich-based task display: shows a spinner + description while running,
    swaps to a ✔ DONE / ✘ FAILED tick when finished, and lets you push
    temporary "sublines" underneath to show progress info.
    """

    def __init__(
        self,
        description: str,
        spinner: str = "dots",
        subline_prefix: str = "   \u21b3 ",  # "   ↳ "
    ):
        self.description = description
        self.subline_prefix = subline_prefix
        self._spinner = Spinner(spinner, text="")
        self._sublines: List[_Info] = []
        self._done = False
        self._success = True

    def _render(self) -> Group:
        if self._done:
            if self._success:
                 main = Text.from_markup(f"{self.description}  [bold green]\u2714 DONE[/]")
            else :
                main = Text.from_markup(f"{self.description}  [bold red]\u2718 FAILED[/]")
        else:
            self._spinner.text = Text(f"{self.description}…")
            main = self._spinner

        sublines = [
            Text(f"{self.subline_prefix}{line}", style="dim italic")
            for line in self._sublines
        ]
        return Group(main, *sublines)

    def _refresh(self) -> None:
        Context().update(self, self._render())

    def start(self) -> "Progress":
        """ Returns self for chaining."""
        Context().update(self, self._render())
        return self

    def update(self, description: str) -> None:
        """Change the main task description text."""
        self.description = description
        self._refresh()


    def info(self, message: str, duration: float|None = None) -> _Info:
        """
        Adds a temporary subline. If `duration` is given, schedules its
        removal after that many seconds using asyncio.sleep
        returns the index of the subline
        """
        info = _Info(self, message, duration)
        self._sublines.append(info)
        self._refresh()
        return info


    def clear_info(self, info : _Info) -> None:
        """Remove one specific subline, or all sublines if none given."""
        if info in self._sublines :
            self._sublines.remove(info)
        else :
            self._sublines.clear()
        self._refresh()

    def complete(self, success: bool = True, final_message: str|None = None) -> None:
        """Mark the task finished: shows a tick (or cross) and stops the live display."""
        self._done = True
        self._success = success
        self._sublines.clear()
        if final_message:
            self.description = final_message
        self._refresh()
        Context().stop(self)

    def fail(self, final_message: str|None = None) -> None:
        """Shortcut for complete(success=False, ...)."""
        self.complete(success=False, final_message=final_message)


    async def __aenter__(self) -> "Progress":
           return self.start()

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> bool:
           if exc_type is not None:
               self.fail(f"{self.description} ({exc_val})")
           else:
               self.complete(success=True)
           return False  # never suppress exceptions


async def main() :
    # Multiple sublines fired concurrently, each auto-clearing on its own
    # timer, without blocking each other or the rest of your event loop.
    async with Progress("Running demo async") as progress:
        progress.info("display info 1...", duration=1.5)
        progress.info("[red] display info 2[/red]...", duration=2.5)
        progress.info("Starting service C...", duration=1.0)
        # meanwhile you could do other async work here concurrently
        await sleep(3)


if __name__ == "__main__":
    run(main())

