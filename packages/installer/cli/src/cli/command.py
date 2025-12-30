#! /usr/bin/env python3
# command line parser base class

from argparse import ( ArgumentParser, Namespace)

class Command(object):

    def __init__(self, parser : ArgumentParser )
        """
        shared elements between every command object
        """
        parser.add_argument("path", help="path to nix configuration")
        parser.add_argument("--flake", help="if true search for 'flake.nix' upward", action='store_true')
        parser.set_defaults(func=self.func)

    async def func(self, arguments : Namespace) :
        """
        run command function
        """
        pass
