#!/usr/bin/env python3
"""
application for os-tools, base for cli and gui apps
"""

from argparse import ArgumentParser

from log import appname
from log import initialize as init_log  # pyright: ignore

from .action import add_parser_actions
from .envars import get_parser_envars, parse_envars

# constants
_PNAME = appname
_DESC = "NonOS utility program"


class App:
    def __init__(self):
        init_log()

    def cli(self):
        envars = get_parser_envars()
        parser = ArgumentParser(
            prog=_PNAME,
            description=_DESC,
            suggest_on_error=True,
            color=True,
            parents=[envars],
        )
        add_parser_actions(parser)
        args = parser.parse_args()
        parse_envars(args)
        args.func(args)
