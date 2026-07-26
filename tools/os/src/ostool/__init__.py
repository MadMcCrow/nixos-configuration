#!/usr/bin/env python3

# imports
from ostool.cli import main
from ostool.init import init
from ostool.install import install
from ostool.update import update

# expose our methods
__all__ = ["init", "install", "update"]

if __name__ == "__main__":
    main()
