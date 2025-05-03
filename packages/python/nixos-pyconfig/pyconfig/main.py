#!/usr/bin/python
#
# Run nixos-pyconfig

#python methods
import logging
import os
# reusable arguments
from .extra.arguments import pyconfigArguments



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






def main() :
    try : 
        logging.basicConfig(filename=f".{pname}.log", level=logging.INFO)
        parser = pyconfigArguments( 
            prog=pname,
            description='a tool to query a nix config'
            )
        filename = parser.filename
        hostname = parser.hostname

        while filename is None or not os.path.exists(filename):
            filename = input("nix file to use :")

        if Flake.isflakepath(filename) :
            _flake = Flake(filename)
            if hostname == None :
                output = Query.select(self._flake.listOutputs(), "select output :")
                hostname = Query.select(self._flake.listOutputs(output), "select host :")
            config = Configuration(flake = self._flake, host = hostname)
        else :
            config = Configuration(configfile=filename)
        if isinstance(options, str) :
           options = options.split(' ')
        elif isinstance(options, list) :
            options = options
        else :
            options = []

        # perform the query :
        query = Query(config, options)

        printres = True
        while True :
            if printres :
                print(f"result of query :\n {query.pretty()}")
                printres = False
            ask = input("Add new options (space separated) to query : (or enter to quit) :")
            if len (ask) == 0 :
                break
            try : 
                query.append(ask.split(' '))
            except Exception as E:
                print(f"failed to query : {E}")
            else :
                printres = True
    except Exception as E :
        print(f"{E} occured while running main script")
        raise E

# allow direct call of program
if __name__ == '__main__':
    main()