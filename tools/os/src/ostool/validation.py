#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

from typing import List

from config import Validator  # pyright: ignore [reportMissingImports]

from .action import add_action
from .envars import EnvironmentVariable

CONFIG_KEYS = EnvironmentVariable("OS_CONFIG_KEYS")


def validate(config_paths: List[str]):
    config_keys_path = CONFIG_KEYS.get()
    validator = Validator(config_keys_path)
    for cfg in config_paths:
        print(f"validating {cfg} with {config_keys_path}")
        validator.validate_config(cfg)


add_action(
    validate,
    "validate config(s)",
    parameter_descriptions={"config_paths": "list of configurations to validate"},
)
