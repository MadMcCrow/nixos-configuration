#!/usr/bin/env python3
"""
Command line builder class
"""

from argparse import ArgumentParser
from typing import List


class Action:
    def __init__(self, name: str) -> None:
        self.name = name

    def configure(self, parser: ArgumentParser):
        # thisd function is virtual and should be implemented by child classes
        pass


class Commands(ArgumentParser):
    def __init__(self, name: str, description: str, actions: List[Action]) -> None:
        super().__init__(
            prog=name,
            description=description,
            suggest_on_error=True,
            color=True,
        )
        self.__subparsers = self.add_subparsers(required=True)
        for action in actions:
            sub = self.__subparsers.add_parser(action.name)
            action.configure(sub)

    def execute(self):
        args = self.parse_args()
        args.func(args)
