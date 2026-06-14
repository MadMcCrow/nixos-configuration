#!/usr/bin/env python3
"""
application for os-tools, base for cli and gui apps
"""

from argparse import ArgumentParser
from types import UnionType
from typing import Callable, Dict, List, Type, Union, get_args, get_origin


class _Parameter:
    def __init__(
        self, key: str, annotation, optional: bool, description: str | None
    ) -> None:
        self._name = key
        self._type: Type = annotation
        self._optional = optional
        self._description = description

    @property
    def argument_kwargs(self) -> Dict[str, str]:
        """Return (arg_name, kwargs) for argparse.add_argument()"""
        kwargs = dict()
        if self._description is not None:
            kwargs["help"] = self._description
        if self._type is bool:
            kwargs["action"] = "store_true"
            return kwargs
        origin = get_origin(self._type)
        if origin is list and not self._optional:
            kwargs["nargs"] = "+"
            return kwargs

        if origin in (Union, UnionType):
            args = get_args(self._type)
            if type(None) in args:
                non_none = [a for a in args if a is not type(None)]
                if len(non_none) == 1 and get_origin(non_none[0]) is list:
                    kwargs["nargs"] = "*"
                else:
                    kwargs["nargs"] = "?"
                return kwargs
        return kwargs

    @property
    def flag(self):
        if self._optional:
            return f"--{self._name}"
        return self._name


class _Action(object):
    def __init__(
        self, function: Callable, description: str, parameters: List[_Parameter]
    ) -> None:
        self.description = description
        self.function = function
        self.parameters = parameters

    @property
    def name(self):
        return self.function.__name__.strip("_")


__actions: List[_Action] = []


def add_parser_actions(parser: ArgumentParser):
    sub = parser.add_subparsers(required=True, prog=parser.prog)
    for action in __actions:
        p = sub.add_parser(
            action.name, help=action.description, description=action.description
        )
        print(action.name)
        for param in action.parameters:
            argstr = ", ".join([f'{k}:"{v}"' for k, v in param.argument_kwargs.items()])
            print(f"{param.flag} ({argstr})")
            p.add_argument(param.flag, **(param.argument_kwargs))  # pyright: ignore
        p.set_defaults(func=action.function)


def add_action(
    function: Callable,
    description: str,
    optional_parameters: List[str] = [],
    parameter_descriptions: Dict[str, str] = {},
):
    parameters = [
        _Parameter(
            n,
            a,
            n in optional_parameters,
            parameter_descriptions[n] if n in parameter_descriptions.keys() else None,
        )
        for n, a in function.__annotations__.items()
    ]
    __actions.append(_Action(function, description, parameters))


def trigger_action(**kwargs):
    func = kwargs["func"]
    args = {k: kwargs[k] for k in func.__annotations__.keys()}
    func(**args)
