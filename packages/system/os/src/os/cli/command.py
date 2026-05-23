#!/usr/bin/env python3
"""
Command line builder class
"""

from argparse import ArgumentParser
from typing import Callable, List


class Commands(ArgumentParser):
    def __init__(self, name: str, description: str) -> None:
        super().__init__(
            prog=name,
            description=description,
            suggest_on_error=True,
            color=True,
        )
        self.subparsers = add_subparsers(required=True)

    def add_command(self, name, arguments: List, func: Callable):
        sub = self.subparsers.add_parser(name)
        for arg in arguments:
            sub.add_argument(*arg)
        sub.set_defaults(func=func)
