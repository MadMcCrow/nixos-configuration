#!/usr/bin/env python3
"""
Install a nonOS config or throw errors.
"""

from pathlib import Path

from log import error as ERROR  # pyright: ignore [reportAttributeAccessIssue]
from shellous import sh

from .build import Builder, BuildException
from .config import Config
from .validate import Validator


class InstallerError(Exception):
    pass


class Installer:
    def __init__(self, config: Config | str, raise_on_error: bool = True):
        """
        installer is not a singleton : you have one per config
        """
        self.progress = 0
        self.config = config
        self.raise_on_error = raise_on_error

    async def install(self, dry_run: bool = False) -> bool:
        """Install the config, after building it

        Args:
            config (Config): The Config object to install.
            raise_on_error (bool) : if true error raise exceptions, otherwise just logs.

        Raises:
            Exception: If mandatory keys are missing from the config.

        Returns:
            True if Config is valid for installation (warnings may exist)

        Logs:
            WARNING: the warnings from the nixos-rebuild command
        """

        def err_or_raise(msg):
            if self.raise_on_error:
                raise InstallerError(msg)
            else:
                ERROR(msg)

        # convert to an actual config if was given as a string
        if isinstance(self.config, Config):
            config = self.config
        else:
            config = Config(self.config)

        # validate :
        if not await Validator().validate(config, False):
            err_or_raise(f"Cannot install {config} : validation failed")
            return False

        # build :
        try:
            outputs = await Builder(config).build()
        except BuildException:
            err_or_raise(f"Cannot install {config} : build failed")
            return False

        # install :
        if "top_level" in outputs:
            pass
            # TODO !!
        return True


async def _run_cmd(path: Path, args):
    args = (str(path) + " ".join(args)).split(" ")
    cmd = sh(args).result().stdout(sh.CAPTURE).stderr(sh.CAPTURE)
