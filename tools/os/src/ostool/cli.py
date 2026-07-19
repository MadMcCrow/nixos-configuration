#!/usr/bin/env python3

from argparse import ArgumentParser
from sys import argv
from os import uname

import ostool

APPNAME = argv[0]



def main() :
    parser = ArgumentParser(APPNAME, description="Install and update your OS")
    subparsers = parser.add_subparsers()
    installer = subparsers.add_parser("install")
    installer.add_argument("--hostname", "-n", default=uname()[1])
    installer.set_defaults(func = ostool.install)
    updater = subparsers.add_parser("update")
    updater.set_defaults(func = ostool.update)
    args = parser.parse_args()
    args.func(args)
