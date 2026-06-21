#!/usr/bin/env python3
"""
environment variables necessary for os-tool
"""

from argparse import SUPPRESS, ArgumentParser, Namespace
from sys import argv

from config import EnvironmentVariable  # pyright: ignore


def make_envars_argument_parser() -> ArgumentParser:
    add_help = "--help" in argv
    p = ArgumentParser(add_help=False)
    if add_help:
        g = p.add_argument_group("ENVARS", "override environment variables")
    else:
        g = p  # ignore groups
    for key in EnvironmentVariable.list_names():
        # custom help message
        var = EnvironmentVariable.get(key)
        help = f"override {var.flag()} (current : {str(var)})"
        # add argument
        g.add_argument(
            f"--{var.name()}",
            help=help if add_help else SUPPRESS,
            default=var.get(),
        )
    return p


def parse_envars(namespace: Namespace):
    """update values based on namespace"""
    for key, var in _envars.items():
        try:
            _value = parser_namespace.__getattribute__(envar._flag.replace("-", "_"))
            print(self.get())
        except Exception as e:
            warning(
                f"{e}:  could not parse environment variable {self._key} from argument parser"
            )
            raise e
