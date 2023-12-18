#!/usr/bin/env python
#
#   colors.py : helper for colored output
#

# global variable
_silent = False

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

# bolden text
def bold(text) :
    return colored(text, Colors.BOLD)

# print error message
def error(text: str):
    print(colored("Error: ", Colors.FAIL) + text)


# enable or disable silent
def set_silent(on: bool) :
    _silent = on

# get global variable and print if not set
def _silenced(text : str) :
    try: 
        if _silent :
          return
    except NameError :
        print("failed to find global variable")
        pass
    print(text)

# Warning message
def warning(text: str):
    _silenced(colored("Warning: ", Colors.WARNING) + text)

# note message
def note(text: str ):
    _silenced(colored("OKCYAN: ", Colors.OKCYAN) + text)

# success message
def success(text: str):
    _silenced(colored("Success: ", Colors.OKGREEN) + text)
