#!/usr/bin/env python3
#
from pathlib import Path
from ostool.config import Config

class InstallException(Exception) :
    pass

async def install(config: str | Path | None, dry_run : bool, **xargs):
    """
    perform the installation process
    """
    c = Config(config)
    if not c.is_valid() :
        raise InstallException(f"{c._root} does not contain a valid configuration. initialize with `init` first.")


    # configs = config_files(config_dir)
    # install = configs["configuration.nix"]
