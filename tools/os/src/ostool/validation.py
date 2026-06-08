#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

from typing import List

from config import Validator  # pyright: ignore [reportMissingImports]

from .action import add_action
from .envars import EnvironmentVariable

CONFIG_KEYS = EnvironmentVariable("config_keys", "OS_CONFIG_KEYS")


def validate(config_paths: List[str]):
    validator = Validator(CONFIG_KEYS.value)
    for configPath in config_paths:
        validator.validate_config(configPath)


add_action(validate, "validate config(s)")
