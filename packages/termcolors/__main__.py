#!/usr/bin/python
# __main__.py parse command line arguments and call functions
try :
    from argparse import ArgumentParser
    from sys import exit
    import colors
    # parse arguments
    parser = ArgumentParser(
                            prog='terminal color and effect ANSI code finder',
                            description='allows you to test colors in your terminal',
                            epilog='works on all platforms, result may differ')
    parser.add_argument('foreground', help='integer to test as foreground')
    parser.add_argument('-b', '--background', help='integer to test as background', default=None)
    parser.add_argument('-s', '--style', help='integer to test as style', default=None)
    args = parser.parse_args()
    code = colors.get_color_code(args.foreground, args.background, args.style)
    print(f'{code}{repr(code)}{colors.clear_code}')
except Exception as E:
    print(f'Error occured: {E}') 
    exit(1)
else :
    print('\x1b[7;50;93mThat\'s all Folks !\x1b[0m')
    exit(0)