#!/usr/bin/env python3
"""
environment variables necessary for os-tool
"""

from argparse import SUPPRESS, ArgumentParser, Namespace
from os import getenv
from sys import argv
from typing import Dict

from log import warning

# keep track of all environment variables defined
_envars: Dict[str, EnvironmentVariable] = {}


class EnvironmentVariable:
    def __init__(self, flag: str, KEY: str):
        if flag not in _envars.keys():
            self.flag = flag
            self.key = KEY
            self.value = getenv(self.key)
            _envars[flag] = self  # add to the unique list
        else:
            self = _envars[flag]

    def parse(self, parser_namespace: Namespace):
        try:
            self.value = parser_namespace.__getattr__(self.flag)
        except Exception as e:
            warning(
                f"{e}:  could not parse environment variable {self.key} from argument parser"
            )

    def __str__(self):
        return str(self.value)


def get_parser_envars() -> ArgumentParser:
    add_help = "--help" in argv
    p = ArgumentParser(add_help=False)
    if add_help:
        g = p.add_argument_group("ENVARS", "override environment variables")
    else:
        g = p  # ignore groups
    for key, var in _envars.items():
        # custom help message
        help = f"override {var.key} (current : {var.value})"
        # add argument
        g.add_argument(
            f"--{var.flag}",
            help=help if add_help else SUPPRESS,
            default=var.value,
        )
    return p


def parse_envars(namespace: Namespace):
    """update values based on namespace"""
    for key, var in _envars.items():
        var.parse(namespace)
