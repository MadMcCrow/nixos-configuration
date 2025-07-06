#!/usr/bin/python
#
# Run nixos-pyinstaller

#python imports
import argparse
import logging
import sys

# our other package
from pyconfig import PyconfigArguments

_pname = "nixos-pyinstall"

def main(argv = sys.argv ) :
    try : 
        logging.basicConfig(filename=f".{_pname}.log", level=logging.INFO)
        args = PyconfigArguments( 
            prog=_pname,
            description='a tool install a nixos config'
            )
    

    except Exception as E :
        print(f"{E} occured while running main script")
        raise E
        sys.exit(1)

# allow direct call of program
if __name__ == '__main__':
    main()