#!/usr/bin/python
#
# Run nixos-pyconfig

#python modules :
import logging
import os
import json

# import our modules :
from .arguments import PyconfigArguments
from ..nix import Flake, Configuration
from ..query import Query

# program name
_pname="nixos-pyconfig"

def select(options : list, question : str = "please choose :") :
        " simple menu question "
        choice = -1
        optionrange = range (0,len(options))
        while choice not in optionrange :
            print(question)
            for i in optionrange : 
                print(f"{i+1} - {options[i]}")
            choice = int(input()) - 1
        return options[choice]


def select_host_name(flake : Flake) -> str : 
    output = select(flake.listOutputs(), "select output :")
    return select(flake.listOutputs(output), "select host :")

def main() :
    try : 
        logging.basicConfig(filename=f".{_pname}.log", level=logging.INFO)
        parser = PyconfigArguments( 
            prog=_pname,
            description='a tool to query a nix config'
            )
        # get nix file :
        filename = parser.filename 

        # make sure filename is legit :
        while filename is None or not os.path.exists(filename):
            print("filename option requiered !")
            filename = input("nix file to use :")

        # get configuration
        if Flake.isflakepath(filename) :
            flake = Flake(filename)
            hostname = parser.hostname or select_host_name(flake)
            config = Configuration(flake = flake, host = hostname)
        else :
            hostname = parser.hostname # not necessary anyway
            config = Configuration(configfile = filename)
    
        # get the options : 
        options  = parser.options

        # perform the query :
        query = Query(config, options)

        # print results :
        printres = True
        while True :
            if printres :
                print(f"result of query :\n {json.dumps(query.result, indent = 4)}")
                printres = False
            ask = input("Add new options (space separated) to query : (or enter to quit) :")
            if len (ask) == 0 :
                break
            try : 
                query = Query(config, ask.split(' '))
            except Exception as E:
                print(f"failed to query : {E}")
                raise
            else :
                printres = True
    except Exception as E :
        print(f"{E} occured while running main script")
        raise E

# allow direct call of program
if __name__ == '__main__':
    main()