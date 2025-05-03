#!/usr/bin/python
#
# configuration query arguments : reusable query arguments !

import sys
from argparse import ArgumentParser

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
        try :
            if self._argv == sys.argv[1:] :
                return self._args
        except : 
            self._args = self.parse_args(argv)
            self._argv = argv
            return self._args
            
    @property
    def hostname(self) -> str :
        arg = self._getArgs().hostname
        if isinstance(arg, str) :
            return arg.strip()
        return ""

    @property
    def filename(self) -> str :
        arg = self._getArgs().filename
        if isinstance(arg, str) :
            return arg.strip()
        return ""
        

    @property
    def options(self) -> list :
        arg = self._getArgs().options
        if isinstance(arg, str) :
            return arg.split(' ')
        if isinstance(arg, list) :
            return arg
        return []

