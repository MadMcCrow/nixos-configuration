#!/usr/bin/env python3

from argparse import ArgumentParser
from asyncio import run
from os import uname
from sys import argv

import ostool

APPNAME = argv[0]


def main():

    # shared options
    common_options = ArgumentParser(add_help=False)
    common_options.add_argument("--config", "-c", help="config directory", default="/etc/nixOS")
    common_options.add_argument("--quiet", "-q", action="store_true")
    # app parser
    parser = ArgumentParser(
        APPNAME, description="Install and update your OS", parents=[common_options]
    )
    subparsers = parser.add_subparsers()
    # generate a config
    init = subparsers.add_parser("init", parents=[common_options])
    init.add_argument("--hostname", "-n", default=uname()[1])
    init.add_argument("--edit", "-e", action="store_true")
    init.set_defaults(func=ostool.init)
    # install a config
    installer = subparsers.add_parser("install", parents=[common_options])
    installer.add_argument("--dry-run", "-n", help="perform a dry run install, but do not install")
    installer.set_defaults(func=ostool.install)
    # update a config
    updater = subparsers.add_parser("update", parents=[common_options])
    updater.set_defaults(func=ostool.update)

    args = parser.parse_args()
    if hasattr(args, "func"):
        run(args.func(**vars(args)))
    else:
        parser.print_help()
