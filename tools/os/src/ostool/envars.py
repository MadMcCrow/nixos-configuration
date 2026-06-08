#!/usr/bin/env python3
"""
environment variables necessary for os-tool
"""

from argparse import ArgumentParser, Namespace
from os import getenv
from typing import Dict

from log import warning

# keep track of all environment variables defined
__envars: Dict[str, EnvironmentVariable] = {}


class EnvironmentVariable:
    def __init__(self, flag: str, KEY: str):
        if flag not in __envars.keys():
            self.flag = flag
            self.key = KEY
            self.value = getenv(self.key)
            __envars[flag] = self  # add to the unique list
        else:
            self = __envars[flag]

    def parse(self, parser_namespace: Namespace):
        try:
            self.value = parser_namespace.__getattr__(self.flag)
        except Exception as e:
            warning(
                f"{e}:  could not parse environment variable {self.key} from argument parser"
            )

    def __str__(self):
        return str(self.value)


def add_parser_envars(parser: ArgumentParser):
    group = parser.add_argument_group("ENVARS")
    for key, var in __envars.items():
        group.add_argument(
            f"--{var.flag}",
            help=f"override {var.key} (current : {var.value})",
            default=var.value,
        )


def parse_envars(namespace: Namespace):
    """update values based on namespace"""
    for key, var in __envars.items():
        var.parse(namespace)
