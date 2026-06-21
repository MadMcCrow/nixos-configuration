#!/usr/bin/env python3
"""
application for os-tools, base for cli and gui apps
"""

from argparse import SUPPRESS, ArgumentParser
from sys import argv

from config import EnvironmentVariable  # pyright: ignore [reportAttributeAccessIssue]
from log import appname, init_log, warning

from . import actions

# constants
_PNAME = appname
_DESC = "NonOS utility program"


class App:
    def __init__(self):
        init_log()
        add_help = "--help" in argv
        base_parser = ArgumentParser(add_help=False)
        if add_help:
            g = base_parser.add_argument_group(
                "ENVARS", "override environment variables"
            )
        else:
            g = base_parser  # ignore groups
        for var in EnvironmentVariable.list_variables():
            # custom help message
            help = f"override {var.flag()} (current : {str(var)})"
            # add argument
            g.add_argument(
                f"--{var.key()}",
                help=help if add_help else SUPPRESS,
                default=str(var),
            )
        self._parser = ArgumentParser(
            prog=_PNAME,
            description=_DESC,
            suggest_on_error=True,
            color=True,
            parents=[base_parser],
        )
        actions.add_parser_actions(self._parser)

    def run(self):
        self._args = self._parser.parse_args()
        self.parse_envars()
        actions.trigger_actions(**vars(self._args))

    def parse_envars(self):
        """update values based on namespace"""
        for var in EnvironmentVariable.list_variables():
            try:
                _value = self._args.__getattribute__(var.key().replace("-", "_"))
            except Exception as e:
                warning(
                    f"{e}:  could not parse environment variable {var.flag()} from argument parser"
                )


def main():
    """run application"""
    app = App()
    app.run()


if __name__ == "__main__":
    main()
