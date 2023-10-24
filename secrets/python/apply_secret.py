#!/usr/bin/env python
#
#   apply_secret.py : decrypt an encrypted file to a given location
#

# Python imports
import argparse
from sys import exit;

# encryption
from age_crypt import decrypt
# io
from colors import *
from files import *

# main implementation for commandline
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
        # K and P are the same :
        parser.add_argument("-k", "--keys",  dest="keys", nargs='+', help="private keys path",  metavar="KEY")
        parser.add_argument("-i", "--int", dest="input",  help="input file (full path)", metavar="IN")
        parser.add_argument("-o", "--out", dest="output", help="output file (full path)", metavar="OUT")
        parser.add_argument("-F", "--force", dest="force", help="force write output", action='store_true')
        parser.add_argument("-s", "--silent", dest="silent", help="silent, only output errors", action='store_true')
        parser.add_argument("-u", "--user",dest="user", help="owner of the encrypted file", metavar="USER")
        parser.add_argument("-g", "--group",dest="group", help="usergroup of the encrypted file (if different from the group of owner)", metavar="GROUP")
        args = parser.parse_args()

        # adapt/parse the arguments
        outfile = args.output
        if outfile == None :
            error("no input provided")
            if not args.silent :
                parser.print_help()
            exit(1)
        infile = args.input
        if infile == None :
            error("no output provided")
            if not args.silent :
                parser.print_help()
            exit(1)

        # remove doubles
        keys = list(set(args.keys))
        # make sure we have a key
        if  len(keys) <= 0 :
            error("Missing private key")
            if not args.silent :
                parser.print_help()
            exit(1)


        # decrypt to variable
        result = decrypt(keys, infile)

        # fail to decrypt
        if result == None :
            error("Cannot decrypt secret")
            exit(1)

        # compare with already decrypted file :
        if  fileExists(outfile) :
            existing = readFile(outfile)
            if existing == result :
                note("File already decrypted", args.silent)
                if setOwnership(outfile, args.user, args.group)  :
                   success("Ownership of encrypted file changed")
                exit(0)
            elif args.force != True :
                    error("already present file differs from decrypted secret")
                    exit(1)
            else :
                removeFile(outfile)
                # continue

        # write decrypted secret
        if writeFile(outfile, result) != None :
            success(f"{outfile} decrypted with ssh key")
            if setOwnership(outfile, args.user, args.group)  :
                note(f"Ownership of {outfile} changed to {args.user}", args.silent)
            exit(0)

    # handle exceptions :
    except KeyboardInterrupt :
        error("user interrupted the process, exiting")
        exit(1)
    except PermissionError :
        error("cannot decrypt secret, permission denied (try again with sudo)")
        exit(1)
    except Exception as E :
        error(f"unhandled error {E}")
        exit(1)
    else :
        success("nothing to do")
        exit(0)
