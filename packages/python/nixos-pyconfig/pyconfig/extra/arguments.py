#!/usr/bin/python
#
# configuration query arguments : reusable query arguments !

import sys
from argparse import ArgumentParser
from . import Query

class PyconfigArguments(ArgumentParser) :

    def __init__(self, **kargs) :
            """
                Create query arguments
            """
            super().__init__(**kargs)      
            self.add_argument('-f', '--filename', help="file (or flake) to use for query", default=".")
            self.add_argument('-m', '--hostname', help="hostname/machine for configuration") 
            self.add_argument('-o', '--options', nargs='+', help="options to query")
               
    def _getArgs(self, argv = sys.argv[1:]) :
            if self._argv != sys.argv[1:] :
                self._args = self.parse_args(argv)
            return self._args

    @property
    def hostname(self) :
        return self._getArgs().hostname

    @property
    def filename(self) :
        return self._getArgs().filename

    @property
    def options(self) :
        return self._getArgs().options

