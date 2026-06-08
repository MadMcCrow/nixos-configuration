#!/usr/bin/env python3
"""
application for os-tools, base for cli and gui apps
"""

from argparse import ArgumentParser
from types import UnionType
from typing import Callable, List, Tuple, Type, Union, get_args, get_origin


class _Parameter:
    def __init__(self, key: str, annotation) -> None:
        self.name = key
        self.type: Type = annotation

    @property
    def argument_spec(self) -> Tuple[str, dict]:
        """Return (arg_name, kwargs) for argparse.add_argument()"""
        dashname = f"--{self.name.replace('_', '-')}"
        kwargs = {}
        if self.type is bool:
            return dashname, {
                "action": "store_true",
            }
        origin = get_origin(self.type)
        if origin is list:
            return self.name, {
                "nargs": "*",
            }
        if origin in (Union, UnionType):
            args = get_args(self.type)
            if type(None) in args:
                non_none = [a for a in args if a is not type(None)]
                if len(non_none) == 1 and get_origin(non_none[0]) is list:
                    kwargs["nargs"] = "*"
                else:
                    kwargs["nargs"] = "?"
                return dashname, kwargs
        return self.name, kwargs


class _Action(object):
    def __init__(self, function: Callable, description: str) -> None:
        self.description = description
        self.function = function

    @property
    def name(self):
        return self.function.__name__.strip("_")

    @property
    def parameters(self):
        params = []
        for k, v in self.function.__annotations__.items():
            params.append(_Parameter(k, v))
        return params


__actions: List[_Action] = []


def add_parser_actions(parser: ArgumentParser):
    sub = parser.add_subparsers(required=True, prog=parser.prog)
    for action in __actions:
        p = sub.add_parser(
            action.name, help=action.description, description=action.description
        )
        for param in action.parameters:
            spec = param.argument_spec
            p.add_argument(spec[0], **(spec[1]))
        p.set_defaults(func=action.function)


def add_action(function: Callable, description: str):
    __actions.append(_Action(function, description))
