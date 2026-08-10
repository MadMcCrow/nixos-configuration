#! /usr/bin/env python3
# need nix package "npins"

# python
from pathlib import Path

# ours
from shared.awaitable import Awaitable
from shared.exceptions import ShellException, assert_cmd
from shared.tui import Progress

# uv
from shellous import sh  # pyright: ignore [reportMissingImports]


class npins(Awaitable):
    def __init__(
        self, args, *, dir: Path | str = "", description: str = "", display: bool = True
    ) -> None:
        """initialize our npins accessor"""
        assert_cmd("npins")
        # ensure directory exists
        self._dir = Path(dir).resolve()
        self._dir.parent.mkdir(parents=True, exist_ok=True)
        self._cmd = sh(["npins", "-d", str(self._dir)])
        self._desc = description
        self._display = display
        self._args = args

    async def _exec(self):
        """Run a subcommand while optionnally showing a spinner."""
        cmd = self._cmd(self._args).stderr(sh.STDOUT).stdout(sh.CAPTURE)
        log = []

        def parse_line(line: str):
            line = line.rstrip()
            if line.startswith("Err"):
                log.append(f"ERROR: {line.removeprefix('Error:').strip()}")
                return line.removeprefix("Error:")
            elif line.startswith("[INFO"):
                info = line.split("]", 1)[-1].strip()
                log.append(f"INFO: {info.strip()}")
                return info
            elif line.startswith("[WARN"):
                warn = line.split("]", 1)[-1].strip()
                log.append(f"WARNING: {warn.strip()}")
                return warn

        ret = None
        async with cmd as run:
            if run.stdout is not None:
                async for line in run.stdout:
                    if self._display:
                        async with Progress(self._desc) as progress:
                            with progress.info("") as info:
                                info.update(parse_line(line.decode()))
                    else:
                        parse_line(line.decode())
            await run._wait()
            ret = run.returncode
        if ret != 0:
            args: list[str] = [str(x) for x in cmd.args]
            raise ShellException(
                cmd, message=f'ERROR : `{" ".join(args)}` failed,\n output was: "{"\n".join(log)}" '
            )


class npins_add(npins):
    def __init__(
        self,
        platform: str,
        owner: str,
        repo: str,
        revision: str | None = None,
        branch: str | None = None,
        name: str | None = None,
        dir: Path | str = "",
        description: str = "",
        display: bool = True,
    ) -> None:
        """specialized npin add command for readability and simplicity"""
        args = ["add", platform, owner, repo]
        if revision and branch:
            args.extend(["--at", revision, "--branch", branch])
        if name:
            args.extend(["--name", name])
        super().__init__(args = args, dir = dir, description=description, display=display)
