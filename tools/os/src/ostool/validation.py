#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

from argparse import ArgumentParser, Namespace
from os import getenv

# config is provided by uv
from config import Validator  # pyright: ignore [reportMissingImports]

from .cli import Action


class ValidateAction(Action):
    def __init__(self) -> None:
        super().__init__("validate", self.cli_validate, "validate a configuration")

    def configure(self, parser: ArgumentParser):
        parser.add_argument("config_path", type=str, nargs="+")
        parser.add_argument(
            "--config-keys",
            help="path to the config-keys file",
            nargs="?",
            default=getenv("OS_CONFIG_KEYS"),
        )

    def cli_validate(self, args: Namespace):
        validator = Validator(args.config_keys)
        for configPath in args.config_path:
            validator.validate_config(configPath)
