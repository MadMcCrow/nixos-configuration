#!/usr/bin/env python3
"""
application for os-tools, base for cli and gui apps
"""

from log import appname, init_log

# import will add actions
__all__ = ["build", "validation"]
from .actions import (
    build,
    validation,
)

# constants
_PNAME = appname
_DESC = "NonOS utility program"


class App:
    def __init__(self):
        init_log()

    def run(self):
        pass


def main():
    """run application"""
    app = App()
    app.run()


if __name__ == "__main__":
    main()
