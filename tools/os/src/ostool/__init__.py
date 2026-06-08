#!/usr/bin/env python3
"""
OS tool entry point
"""

__all__ = ["build", "validation"]
from . import build, validation  # pyright: ignore
from .app import App


def main():
    app = App()
    app.cli()


if __name__ == "__main__":
    main()
