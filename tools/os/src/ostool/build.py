#!/usr/bin/env python3
"""
build configs with our tool
"""

from typing import List

from config import Builder, Validator  # pyright: ignore [reportMissingImports]

from .action import add_action
from .envars import EnvironmentVariable

# environment variables
CONFIG_KEYS = EnvironmentVariable("OS_CONFIG_KEYS")
FLAKE_PATH = EnvironmentVariable("OS_FLAKE_PATH")
MK_DRV = EnvironmentVariable("OS_MAKE_SYSTEM")


def build(config_paths: List[str]):
    validator = Validator(CONFIG_KEYS.get())
    builder = Builder(FLAKE_PATH.get(), MK_DRV.get())
    for cfg in config_paths:
        if validator.validate_config(cfg):
            builder.build(cfg)


add_action(
    build,
    "build config(s)",
    parameter_descriptions={"config_paths": "list of configurations to build"},
)
