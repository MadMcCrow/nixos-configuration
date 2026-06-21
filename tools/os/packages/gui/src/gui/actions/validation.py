#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

from typing import List

from config import Validator  # pyright: ignore [reportAttributeAccessIssue]


def validate(config_paths: List[str]):
    validator = Validator()
    for cfg in config_paths:
        print(f"validating {cfg}")
        validator.validate_config(cfg)
