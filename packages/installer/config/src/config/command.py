#! /usr/bin/env python3
# command line parser base class

from argparse import Namespace

from cli import Command as CommandBase

from .flake import Flake


class Command(CommandBase):
    """
    query config command
    """

    async def func(self, args: Namespace):
        if args.flake:
            flake = Flake(args.path)
            flake.config
