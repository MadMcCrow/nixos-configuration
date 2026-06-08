#!/usr/bin/env python3
"""
build a nonOS config or throw errors.
"""

# our logging module
from log import error as ERROR  # pyright: ignore [reportAttributeAccessIssue]
from log import info as INFO  # pyright: ignore
from shelltastic import shell

from .config import Config

# we should pass those from environment variables :


class Builder:
    """
    async object to run the nix build process and monitor it
    """

    def __init__(self, flake_path: str, mk_derivation: str):
        self._nix_derivation_func = mk_derivation  # "lib.mkSystem"
        self._nix_flake_path = flake_path  # "github:MadMcCrow/nonOS"

    def build(self, config: Config | str):
        config_path = config.path if isinstance(config, Config) else config
        drv = f'(builtins.getFlake "{self._nix_flake_path}").{self._nix_derivation_func} {config_path}'
        # build
        res = shell.run(["nix", "build", "--impure", f'--expr "{drv}"'])
        # TODO : check for encoding
        encoding = "ascii"
        if res.stderr is not None:
            ERROR(res.stderr.decode(encoding))
        if res.stdout is not None:
            INFO(res.stdout.decode(encoding))
