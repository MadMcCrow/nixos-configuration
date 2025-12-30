#! /usr/env python3

from argparse import ArgumentParser
from asyncio import run
from sys import argv

from config import Command as config_cmd
from install import Command as install_cmd


def main():
    parser = ArgumentParser(
        description="tool to parse and install nixos configurations"
    )
    subparsers = parser.add_subparsers(description="available subcommands")
    # add commands :
    config_cmd(subparsers.add_parser("config"))
    install_cmd(subparsers.add_parser("install"))
    # parse arguments :
    args = parser.parse_args(argv[1:])
    # run async program
    run(args.func(args))
