#!/usr/bin/python
#
# script to install nixos on a machine 
#
# python script to replace the old bash install script
# we still run bash commands in the end, but the processing 
# of inputs is done in python for simplicity
# 

import sys, argparse
import modules

if __name__ == "__main__" :
    try:
        parser = argparse.ArgumentParser(
                        prog='nixos install script generator',
                        description='build a shell script to help you install your os!',
                        epilog='used for every system !')
        parser.add_argument('hostname')
        parser.add_argument('-f', '--flake', default='.')
        parser.add_argument('-m', '--mount',action='store_true')
        args = parser.parse_args()
        print(f'generating install script for system : \x1b[2;25;10m{args.hostname}#{args.flake}\x1b[0m')
        modules.script(args.hostname, f'./install-{args.hostname}.sh',not args.mount)
        # end the program in class !
    except Exception as E:
        print(f'Error occured: {E}') 
        raise E
    else :
        print('\x1b[7;50;93mThat\'s all Folks !\x1b[0m')
        sys.exit(0)


    