#!/usr/bin/env python3
"""
OS tool entry point
"""

from .cli import Commands
from .validation import ValidateAction


def main() -> None:
    # for now, just run the CLI
    cli = Commands(
        "os",
        "NonOS utility program",
        # list of actions goes here :
        [
            ValidateAction(),
        ],
    )
    cli.execute()


if __name__ == "__main__":
    main()
