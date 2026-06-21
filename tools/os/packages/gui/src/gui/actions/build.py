#!/usr/bin/env python3
"""
build configs with our tool
"""

from typing import List

from config import Builder, Validator  # pyright: ignore [reportAttributeAccessIssue]


def build(config_paths: List[str]):
    validator = Validator()
    builder = Builder()
    for cfg in config_paths:
        if validator.validate_config(cfg):
            builder.build(cfg)
