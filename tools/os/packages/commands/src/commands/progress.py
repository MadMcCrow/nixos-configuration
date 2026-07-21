#! /usr/bin/env python3

# python deps
from asyncio import create_task, run, sleep
from typing import List

# rich deps
from rich.console import Console, Group
from rich.live import Live
from rich.spinner import Spinner
from rich.text import Text

# shared console between invocations
_console = Console()

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
    temporary "sublines" underneath to show progress info. Works as a
    context manager.

    Usage:
        from task_display import Progress
        import time
        with TaskDisplay("Downloading dataset") as task:
            task.info("Connecting to server...")
            time.sleep(1)
            task.info("Fetching file 1/3")
            time.sleep(1)
            task.info("Fetching file 2/3")
            time.sleep(1)
        # exiting the `with` block cleanly marks it DONE
        # an exception inside the block marks it FAILED instead

    Or without `with`:

        task = TaskDisplay("Doing something").start()
        task.info("working...")
        time.sleep(1)
        task.complete()          # -> tick
        # or: task.fail("could not connect")   # -> cross
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
        self._live: Live|None = None


    def _render_main_text(self) -> Text:
        if self._done:
            if self._success:
                return Text.from_markup(f"{self.description}  [bold green]\u2714 DONE[/]")
            return Text.from_markup(f"{self.description}  [bold red]\u2718 FAILED[/]")
        return Text(f"{self.description}…")

    def _render(self) -> Group:
        if self._done:
            main = self._render_main_text()
        else:
            self._spinner.text = self._render_main_text()
            main = self._spinner

        sublines = [
            Text(f"{self.subline_prefix}{line}", style="dim italic")
            for line in self._sublines
        ]
        return Group(main, *sublines)

    def _refresh(self) -> None:
        if self._live is not None:
            self._live.update(self._render())

    def start(self) -> "Progress":
        """Start the live display. Returns self for chaining."""
        self._live = Live(
            self._render(),
            console=_console,
            refresh_per_second=12,
            transient=False,
        )
        self._live.start()
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
        if self._live is not None:
            self._live.stop()

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

