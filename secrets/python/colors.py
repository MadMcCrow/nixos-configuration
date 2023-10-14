#!/usr/bin/env python
# colored output

# enum for lookup
class Colors:
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# wrap text in color
def colored(text : str, color ) :
    return '\0'.join([color, text, Colors.ENDC])
