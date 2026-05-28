#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

from argparse import ArgumentParser

from cli.command import Action

# from config.validator import Validator


class ValidateAction(Action):
    def configure(self, parser: ArgumentParser):
        parser.add_argument("config_path", type=str)
        parser.set_defaults(func=self.cli_validate)

    def cli_validate(self, args):
        validate(args.config_path)


def validate(configPath: str):
    print(configPath)
    pass
