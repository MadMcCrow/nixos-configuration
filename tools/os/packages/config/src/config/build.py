#!/usr/bin/env python3
"""
build a nonOS config or throw errors.
"""

from asyncio import gather, to_thread
from enum import Enum
from json import JSONDecodeError
from json import loads as load_json
from pathlib import Path
from typing import Dict

from log import debug
from shellous import Command, sh

from .config import Config
from .envars import EnvironmentVariable
from .singleton import SingletonMeta

# environment variables
FLAKE_PATH = EnvironmentVariable("OS_FLAKE_PATH")
MK_DRV = EnvironmentVariable("OS_MAKE_SYSTEM")
BUILD_TMP = EnvironmentVariable("OS_BUILD_TEMP")


class NixEvent:
    _status: EventStatus
    _progress: float

    class EventStatus(Enum):
        RUNNING = 1
        FAILED = 2
        DONE = 3

    def __init__(self, text):
        self._status = self.EventStatus.RUNNING
        self._progress = 0.0
        self._text = text

    def progress(self, value: float):
        assert self._status == self.EventStatus.RUNNING, (
            "tried to update progress after event is done"
        )
        self._progress = value

    def fail(self):
        self._status = self.EventStatus.FAILED

    def done(self):
        self._progress = 1.0
        self._status = self.EventStatus.DONE


class Builder(metaclass=SingletonMeta):
    """
    object to run async build commands run the nix build process and monitor it
    """

    _events: Dict[str, NixEvent] = {}

    def __init__(self):
        self._build_roots: Dict[Config, Path] = {}
        self._events = {}

    def _make_cmd(self, config: Config) -> Command:
        """prepare the nix command"""
        flake_path = str(FLAKE_PATH)
        if Path(flake_path).is_dir():
            # prefix it like a path
            self._nix_flake = f"path:{flake_path}"
        else:
            # assume that the user took care of prefixing it for us, ie. "github:MadMcCrow/nonOS"
            self._nix_flake = flake_path
        drv = f'(builtins.getFlake "{self._nix_flake}").{str(MK_DRV)} {config.path}'
        args = [
            "build",
            "nix",
            "--impure",  # we're using absolute paths
            "--no-link",  # do not produce "result output"
            "--print-out-paths",  # final output is the result path to then symlink
            "--log-format internal-json",  # output progress and events as json
            "-v",  # notify every event
            f"--expr '{drv}'",
        ]
        return sh(args).set(
            inherit_env=False,
            encoding="utf8",
        )

    async def build(self, config: Config):
        """
        build a config by adding it to the pool of builds
        """
        # prepare the reading of the output
        cmd = self._make_cmd(config).result().stdout(sh.CAPTURE).stderr(sh.CAPTURE)
        # run it async
        async with cmd.stderr(sh.CAPTURE) as proc:
            # inline coro to parse stderr :
            async def read_stderr():
                if proc.stderr is None:
                    raise TypeError(f"could not get stderr for {cmd.name}")
                async for line in proc.stderr:
                    line = str(line).strip()
                    if not line.startswith("@nix "):
                        continue
                    try:
                        event = load_json(line[5:])
                    except JSONDecodeError:
                        continue

                    action = event.get("action")
                    if action == "start":
                        self._events[event["id"]] = NixEvent(event.get("text", ""))
                    elif action == "result" and event.get("type") == 105:
                        done, expected, running, failed = event["fields"]
                        if expected:
                            try:
                                self._events[event["id"]].progress(done / expected)
                                if expected == done:
                                    self._events[event["id"]].done()
                            except KeyError:
                                pass
                        if failed:
                            self._events[event["id"]].fail()

                    elif action == "stop":
                        self._events[event["id"]].done()

                    elif action == "msg" and event.get("level", 99) <= 1:
                        debug(f"[BUILD] {event.get('msg', '')}")

            # inline coro to parse stdout :
            async def read_stdout():
                if proc.stdout is None:
                    raise TypeError(f"could not get stdout for {cmd.name}")
                async for line in proc.stdout:
                    result_path = Path(str(line).strip())
                    if result_path.exists():
                        # Create symlinks asynchronously
                        build_dir = Path("./result").joinpath(
                            config.name, result_path.stem
                        )
                        await to_thread(build_dir.unlink, missing_ok=True)
                        await to_thread(build_dir.symlink_to, result_path, True)

            await gather(read_stderr(), read_stdout())
            return
