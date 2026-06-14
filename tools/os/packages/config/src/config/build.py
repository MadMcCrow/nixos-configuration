#!/usr/bin/env python3
"""
build a nonOS config or throw errors.
"""

# our logging module
from pathlib import Path

from log import error as ERROR  # pyright: ignore [reportAttributeAccessIssue]
from log import info as INFO  # pyright: ignore
from shelltastic import DisplayMode, shell
from shelltastic.exception import ShellException

from .config import Config


def _decode(stream: bytes | None) -> str:
    if stream is not None:
        return stream.decode("ascii")
    return ""


class BuildException(Exception):
    pass


class Builder:
    """
    async object to run the nix build process and monitor it
    """

    def __init__(self, flake_path: str, mk_derivation: str):
        # this should be our method that create a system derivation
        # by default, this is "lib.mkSystem"
        self._nix_derivation_func = mk_derivation
        if Path(flake_path).is_dir():
            # prefix it like a path
            self._nix_flake = f"path:{flake_path}"
        else:
            # assume that the user took care of prefixing it for us
            # "github:MadMcCrow/nonOS"
            self._nix_flake = flake_path
        # TODO :
        #       We should perform checks to verify
        #       the path and nix function exists !

    def build(self, config: Config | str) -> bool:
        config_path = config.path if isinstance(config, Config) else config
        drv = f'(builtins.getFlake "{self._nix_flake}").{self._nix_derivation_func} {config_path}'
        # build
        arglist = ["nix", "build", "--impure", f'--expr "{drv}"']
        INFO(f"building {drv}")
        try:
            res = shell.run(
                " ".join(arglist),
                echo_cmd=DisplayMode.DEVNULL,
                stdout_display=DisplayMode.DEVNULL,
                stderr_display=DisplayMode.DEVNULL,
            )
        except ShellException as e:
            msg = f"failed to build {config} :\n{e.cmd} returned {e.returncode}"
            errs = _decode(e.stderr).splitlines()
            outs = _decode(e.stdout).splitlines()

            if len(outs) > 0:
                ll = min(3, len(outs))
                msg += f"last {ll} stdout lines :\n\t{'\n\t'.join(outs[:ll])}"
            if len(errs) > 0:
                ll = min(3, len(errs))
                msg += f"last {ll} stderr lines :\n\t{'\n\t'.join(errs[:ll])}"
            ERROR(msg)
            exit()
            raise BuildException()

        try:
            if res.stderr is not None:
                ERROR(_decode(res.stderr))
            if res.stdout is not None:
                INFO(_decode(res.stdout))
        except Exception as e:
            print(f"{e} : Could not parse shell output")
            pass
        # return true if successful
        return res.returncode == 0
