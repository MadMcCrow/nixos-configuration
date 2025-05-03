#!/usr/bin/python
#
# Run nixos-pyinstaller

#python imports
import argparse
import logging
import sys

# our other package
from pyconfig import QueryArguments

from .steps.main import MainStep, Context

_pname = "nixos-pyinstall"

def main(argv = sys.argv ) :
    try : 
        logging.basicConfig(filename=f".{_pname}.log", level=logging.INFO)
        parser = QueryArguments( 
            prog=_pname,
            description='a tool install a nixos config'
            )
        main_context = Context(parser.Query()) 
        main_step = MainStep(f"install-{main_context.host}", main_context)
        main_step.run()
        
    except Exception as E :
        print(f"{E} occured while running main script")
        sys.exit(1)

# allow direct call of program
if __name__ == '__main__':
    main()