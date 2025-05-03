#!/usr/bin/python
#
# configuration query arguments : reusable query arguments !

import sys
from argparse import ArgumentParser
from . import Query

class QueryArguments(ArgumentParser) :

    def __init__(self, **kargs) :
            """
                Create query arguments
            """
            super().__init__(**kargs)      
            self.add_argument('-f', '--filename', help="file (or flake) to use for query", default=".")
            self.add_argument('-m', '--hostname', help="hostname/machine for configuration") 
            self.add_argument('-o', '--options', nargs='+', help="options to query")
               
    def Query(self, argv = sys.argv[1:]) :
            args = self.parse_args(argv)
            return Query(
                filename = args.filename,
                hostname= args.hostname, 
                options = args.options )