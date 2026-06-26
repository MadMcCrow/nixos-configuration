#!/usr/bin/env python3
"""
build a nonOS config or throw errors.
"""

from asyncio import create_task, gather, to_thread
from enum import Enum
from json import JSONDecodeError
from json import loads as load_json
from pathlib import Path
from shutil import rmtree
from typing import Dict, List

from log import debug
from shellous import Command, sh

from .config import Config
from .envars import EnvironmentVariable

# environment variables
FLAKE_PATH = EnvironmentVariable("OS_FLAKE_PATH")
MK_DRV = EnvironmentVariable("OS_MAKE_SYSTEM")
BUILD_TMP = EnvironmentVariable("OS_BUILD_TEMP")


class BuildException(Exception):
    pass


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

    def __str__(self) -> str:
        return f"{self._text}: {self._progress * 100}%"


class Builder:
    """
    object to run async build commands run the nix build process and monitor it
    """

    _events: Dict[str, NixEvent] = {}

    def __init__(self, config: Config):
        self._build_roots: Dict[Config, Path] = {}
        self._events = {}
        self.config = config

    def _make_cmd(self, output: str) -> Command:
        # TODO : build top_level and installBootLoader
        """prepare the nix command"""
        flake_path = str(FLAKE_PATH)
        if Path(flake_path).is_dir():
            # prefix it like a path
            self._nix_flake = f"path:{flake_path}"
        else:
            # assume that the user took care of prefixing it for us, ie. "github:MadMcCrow/nonOS"
            self._nix_flake = flake_path
        drv = (
            f'(builtins.getFlake "{self._nix_flake}").{str(MK_DRV)} {self.config.path}'
        )
        args = [
            "nix",
            "build",
            "--log-format",
            "internal-json",  # output progress and events as json
            "--impure",  # we're using absolute paths
            "--no-link",  # do not produce "result output"
            "--print-out-paths",  # final output is the result path to then symlink
            "-v",  # notify every event
            "--expr",
            f"({drv}).{output}",
        ]
        return sh(args).set(
            inherit_env=False,
            encoding="utf8",
        )

    async def _build_output(self, output: str) -> Path:
        """
        build a config output
        """
        cmd = self._make_cmd(output).result().stdout(sh.CAPTURE).stderr(sh.CAPTURE)
        build_path = Path("./result").joinpath(self.config.name, output)

        async with cmd.stderr(sh.CAPTURE) as proc:
            # inline coro to parse stderr :
            async def read_stderr():
                if proc.stderr is None:
                    raise TypeError(f"could not get stderr for {cmd.name}")
                async for line in proc.stderr:
                    line = line.decode("utf-8").strip()
                    if not line.startswith("@nix "):
                        continue
                    try:
                        event = load_json(line[5:])
                    except JSONDecodeError:
                        continue

                    action = event.get("action")

                    if action == "msg":
                        if event.get("level", 99) <= 3:
                            debug(f"[BUILD] {event.get('msg', '')}")
                    else:
                        print(event)
                        exit()
                    if action == "start":
                        self._events[event["id"]] = NixEvent(event.get("text", ""))
                    elif action == "result" and event.get("type") == 105:
                        done, expected, running, failed = event["fields"]
                        if expected:
                            try:
                                self._events[event["id"]].progress(done / expected)
                                print(self._events[event["id"]], end="\r")
                                if expected == done:
                                    self._events[event["id"]].done()
                            except KeyError as E:
                                print(f"Error : {E}")
                        if failed:
                            self._events[event["id"]].fail()

                    elif action == "stop":
                        self._events[event["id"]].done()

            # inline coro to parse stdout :
            async def read_stdout():
                if proc.stdout is None:
                    raise TypeError(f"could not get stdout for {cmd.name}")
                async for line in proc.stdout:
                    result_path = Path(line.decode("utf-8").strip())
                    if result_path.exists():
                        # Create symlinks asynchronously
                        if build_path.exists():
                            if build_path.is_file() or build_path.is_symlink():
                                await to_thread(build_path.unlink, missing_ok=True)
                            elif build_path.is_dir():
                                await to_thread(rmtree, str(build_path.absolute()))

                        if not build_path.parent.exists():
                            await to_thread(build_path.parent.mkdir, 0o755, True, True)

                        # create link to build results :
                        await to_thread(build_path.symlink_to, result_path, True)
                        # store for result

            await gather(read_stderr(), read_stdout())
            if build_path.exists():
                return build_path
            else:
                raise BuildException(f"Failed to build {self.config.name}")

    async def build(
        self, outputs: List[str] = ["top_level", "installBootLoader"]
    ) -> Dict[str, Path]:
        """
        build all outputs of config

        PARAMS :
            outputs is the list of outputs you want, by default it's the top level os and the boot loader
        """
        tasks = {o: create_task(self._build_output(o)) for o in outputs}
        values = await gather(*tasks.values())
        return dict(zip(tasks.keys(), values))
