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
    _key: str
    _value: str

    def __init__(self, key: str):
        flag = key.lower().replace("_", "-")
        self._flag = flag
        self._key = key
        if flag not in _envars.keys():
            self._value = getenv(self._key) or ""
            _envars[flag] = self  # add to the unique list
        else:
            self._value = _envars[flag]._value

    def parse(self, parser_namespace: Namespace):
        try:
            self._value = parser_namespace.__getattribute__(
                self._flag.replace("-", "_")
            )
            print(self.get())
        except Exception as e:
            warning(
                f"{e}:  could not parse environment variable {self._key} from argument parser"
            )
            raise e

    def __str__(self):
        return str(self._value)

    def get(self):
        return str(self._value)


def get_parser_envars() -> ArgumentParser:
    add_help = "--help" in argv
    p = ArgumentParser(add_help=False)
    if add_help:
        g = p.add_argument_group("ENVARS", "override environment variables")
    else:
        g = p  # ignore groups
    for key, var in _envars.items():
        # custom help message
        help = f"override {var._key} (current : {var._value})"
        # add argument
        g.add_argument(
            f"--{var._flag}",
            help=help if add_help else SUPPRESS,
            default=var.get(),
        )
    return p


def parse_envars(namespace: Namespace):
    """update values based on namespace"""
    for key, var in _envars.items():
        var.parse(namespace)
