#!/usr/bin/python
#
# Run nixos-pyconfig

#python methods
from .query import Query, QueryArguments
import logging

pname="nixos-pyconfig"

def main() :
    try : 
        logging.basicConfig(filename=f".{pname}.log", level=logging.INFO)
        parser = QueryArguments( 
            prog=pname,
            description='a tool to query a nix config'
            )
        mainquery = parser.Query()
        printres = True
        while True :
            if printres :
                print(f"result of query :\n {mainquery.pretty()}")
                printres = False
            ask = input("Add new options (space separated) to query : (or enter to quit) :")
            if len (ask) == 0 :
                break
            try : 
                mainquery.queryOptions(ask.split(' '))
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