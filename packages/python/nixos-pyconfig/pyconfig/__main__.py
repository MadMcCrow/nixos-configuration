#!/usr/bin/python
#
# Run nixos-pyconfig

#python modules :
import logging
import os
import json

# import our modules :
import argparse

from . import Flake, Configuration

# program name
_pname="nixos-pyconfig"

def main() :
    try : 
        logging.basicConfig(filename=f".{_pname}.log", level=logging.INFO)
        parser = argparse.ArgumentParser( 
            prog=_pname,
            description='a tool to query a nix config'
            )
        parser.add_argument('uri', help="file (or flake) to use for query", default=".")
        parser.add_argument('options', nargs='+', help="options to query")
        args = parser.parse_args()
        print(args)
        config = Configuration(args.uri)
        # print results :
        while True :
            for x in args.options :
                print(f"{x} :\n {config[x]}")
            ask = input("Add new options (space separated) to query : (or enter to quit) :")
            if len (ask) == 0 :
                break
            options = ask.split()
    except Exception as E :
        print(f"{type(E)} occured while running main script : {E}")
        raise E

# allow direct call of program
if __name__ == '__main__':
    main()