#!/usr/bin/env python3
"""
build configs with our tool
"""

from typing import List

from config import Builder, Validator  # pyright: ignore [reportMissingImports]

from .action import add_action
from .envars import EnvironmentVariable

# environment variables
CONFIG_KEYS = EnvironmentVariable("config_keys", "OS_CONFIG_KEYS")
FLAKE_PATH = EnvironmentVariable("flake_path", "OS_FLAKE_PATH")
MK_DRV = EnvironmentVariable("mk_system", "OS_MAKE_SYSTEM")


def build(config_paths: List[str]):
    validator = Validator(CONFIG_KEYS)
    builder = Builder(FLAKE_PATH, MK_DRV)
    for cfg in config_paths:
        if validator.validate_config(cfg):
            builder.build(cfg)


add_action(build, "build config(s)")
