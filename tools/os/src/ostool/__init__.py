#!/usr/bin/env python3

# imports
from ostool.cli import main
from ostool.generate import generate
from ostool.install import install
from ostool.update import update

# expose our methods
__all__ = ["install", "update", "generate"]

if __name__ == "__main__":
    main()
