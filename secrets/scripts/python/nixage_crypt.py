#!/usr/bin/env python
#
#   nixage_crypt : a tool responsible for xxcrypting secrets with ssh keys
#

# Python imports
import os
import argparse
from sys import exit;

# local modules (importing all without namespace like a madman)
from colors import *
from pyage import *
from files import *

def nixage_decrypt(args) :
    """
        Decrypt a age secret to a normal file
    """
    outpath = fixPath(args.output)
    set_silent(args.silent)
    result = decrypt(list(set(args.keys)), args.input)
    if fileExists(outpath) :
        existing = readFile(outpath)
        if existing == result :
            note("File already decrypted")
            return
        elif args.force != True :
                error("already present file differs from decrypted secret")
                raise FileExistsError
        else :
            removeFile(outpath)
    writeFile(outpath, result)


def nixage_encrypt(args) :
    """
        encrypt a normal file to an age secret
    """
    # try decrypt file :
    outpath = fixPath(args.output)
    if fileExists(outpath) :
        if args.force :
           warning("removing already present secret")
           removeFile(outpath)
        elif args.ignore :
            note("File already present, skipping")
            return
        else :
            error("Secret file already present")
            raise FileExistsError
    if args.input != None :
        content = readFile(fixPath(args.input))
    else :
        note(f"enter content for {bold(outpath)}:\n")
        content = input()
    writeFile(outpath, encrypt(list(set(args.keys)), content), true)

def addParserSubcommand(subparsers, name, requireInput, func) :
    parser = subparsers.add_parser(name)
    inputParser = parser.add_argument_group('input', 'input options')
    inputParser.add_argument("-i", "--input", dest="input",  help="input file (full path)", metavar="IN", required=requireInput)
    inputParser.add_argument("-k", "--keys",  dest="keys", nargs='+', help="ssh keys path",  metavar="KEY", required=True)
    outputParser = parser.add_argument_group('output', 'output options')
    outputParser.add_argument("-o", "--output", dest="output", help="output file (with extension)", metavar="OUT", required = True)
    outputParser.add_argument("-U", "--user",dest="user", help="owner in the form USER[:GROUP]", metavar="USER")
    parser.add_argument("-I", "--ignore", dest="ignore", help="ignore errors",                 action='store_true')
    parser.add_argument("-F", "--force",  dest="force",  help="force action (recreate files)", action='store_true')
    parser.add_argument("-S", "--silent", dest="silent", help="silent, only output errors",    action='store_true')
    parser.set_defaults(func=func)
    return parser

# Main Program :
if __name__ == "__main__" :
    try :
        # shared command arguments :
        parent_parser = argparse.ArgumentParser()
       
        #  add subparsers
        parser = argparse.ArgumentParser()
        subparsers = parser.add_subparsers(required = True)
        addParserSubcommand(subparsers, 'encrypt', False, nixage_encrypt)
        addParserSubcommand(subparsers, 'decrypt', True,  nixage_decrypt)
       
        # start parser !
        args = parser.parse_args()

        # check that keys exists:
        missing_keys = [key for key in set(args.keys) if not fileExists(key)]
        if len(missing_keys) != 0 :
            raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), missing_keys[0])

        # do what we asked
        args.func(args)

        # set ownership of created file
        if args.user != None :
            setOwnership(args.output, args.user, args.group)

    # handle exceptions :
    except KeyboardInterrupt :
        error("user interrupted the process, exiting")
    except PermissionError :
        error("cannot age-crypt secret, permission denied (try again with sudo)")
    except EOFError :
        error(f"read error, end of file encountered")
    except FileExistsError :
        error(f"output file {outfile} already exists")
    except Exception as E :
        error(f"{type(E).__name__} : {E}")
    else :
        success("secret operation done")
        exit(0)
    finally :
        exit(1)


        
