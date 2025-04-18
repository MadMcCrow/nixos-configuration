#!/usr/bin/python
# termcolors.py : test your terminal colors


from os import environ
from argparse import ArgumentParser
from sys import exit, stdout

class ANSICOLORS :
    default = 0
    brighter = 1
    underlined = 4
    flashing = 5
    black_foreground = 30
    red_foreground   = 31
    green_foreground = 32
    yellow_foreground = 33
    blue_foreground = 34
    purple_foreground = 35	
    cyan_foreground = 36	
    white_foreground = 37	
    black_background = 40	
    red_background = 41	
    green_background = 42	
    yellow_background = 43	
    blue_background = 44	
    purple_background = 45	
    cyan_background = 46	
    white_background = 47	
    
def has_colors():
    if environ.get('NO_COLOR'):
        return False
    elif environ.get('CLICOLOR_FORCE'):
        return True
    elif environ.get('CLICOLOR'):
        return stdout.isatty()
    else :
        return False

# code to use to remove any previous codes
clear_code = f'\x1b[0m'

# get a code with infos :
def get_color_code(foreground, background, style = None) :
    l = [ style, foreground, background ]
    format = ';'.join(list(map(lambda x: str(x), [s for s in l if s is not None])))
    return f'\x1b[{format}m'


def main() :
    try :
        # parse arguments
        parser = ArgumentParser(
                                prog='terminal color and effect ANSI code finder',
                                description='allows you to test colors in your terminal',
                                epilog='works on all platforms, result may differ')
        parser.add_argument('foreground', help='integer to test as foreground')
        parser.add_argument('-b', '--background', help='integer to test as background', default=None)
        parser.add_argument('-s', '--style', help='integer to test as style', default=None)
        args = parser.parse_args()
        code = get_color_code(args.foreground, args.background, args.style)
        print(f'{code}{repr(code)}{clear_code}')
    except Exception as E:
        print(f'Error occured: {E}') 
        exit(1)
    else :
        print('\x1b[7;50;93mThat\'s all Folks !\x1b[0m')
        exit(0)

# allow direct call of program
if __name__ == '__main__':
    main()