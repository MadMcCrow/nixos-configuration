#!/usr/bin/env python3

from argparse import ArgumentParser
from asyncio import run
from os import uname
from sys import argv

import ostool

APPNAME = argv[0]


def main():
    parser = ArgumentParser(APPNAME, description="Install and update your OS")
    subparsers = parser.add_subparsers()
    # generate a config
    init = subparsers.add_parser("init")
    init.add_argument("--hostname", "-n", default=uname()[1])
    init.add_argument("--edit", "-e", action="store_true")
    init.set_defaults(func=ostool.init)
    # install a config
    installer = subparsers.add_parser("install")
    installer.add_argument("config_path", help="path to the configuration to install")
    installer.set_defaults(func=ostool.install)
    # update a config
    updater = subparsers.add_parser("update")
    updater.set_defaults(func=ostool.update)

    args = parser.parse_args()
    if hasattr(args, "func"):
        run(args.func(**vars(args)))
    else:
        parser.print_help()
