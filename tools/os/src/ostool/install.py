#!/usr/bin/env python3
#
from pathlib import Path


async def install(config_path: str | Path | None):
    """
    perform the installation process
    """
    if config_path is None:
        config_path = Path("./")
    config_dir = Path(config_path)
    assert config_dir.exists(), f"{config_path} is not a valid path"
    # configs = config_files(config_dir)
    # install = configs["configuration.nix"]
