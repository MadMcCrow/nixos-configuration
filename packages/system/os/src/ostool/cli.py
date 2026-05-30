#!/usr/bin/env python3
"""
Command line builder class
"""

from argparse import ArgumentParser
from typing import Callable, List


class Action:
    def __init__(
        self, name: str, function: Callable, description: str | None = None
    ) -> None:
        self.name = name
        self.description = description
        self.function = function

    def configure(self, parser: ArgumentParser):
        # this function is virtual and should be implemented by child classes
        pass


class Commands:
    def __init__(self, name: str, description: str, actions: List[Action]) -> None:
        self.__parser = ArgumentParser(
            prog=name,
            description=description,
            suggest_on_error=True,
            color=True,
        )
        self.__subparsers = self.__parser.add_subparsers(required=True, prog=name)
        for action in actions:
            sub: ArgumentParser = self.__subparsers.add_parser(
                action.name, description=action.description
            )
            sub.set_defaults(func=action.function)
            action.configure(sub)

    def execute(self):
        args = self.__parser.parse_args()
        args.func(args)
