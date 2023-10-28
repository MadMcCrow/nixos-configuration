#!/usr/bin/env python
#
#   gen_secret : a script responsible for encrypting secrets with ssh keys
#

# Python imports
import os
import argparse
from sys import exit;

# local modules
from colors import colored, Colors
from age_crypt import encrypt
from files import *

# main implementation for commandline
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
        parser.add_argument("-k", "--keys", dest="keys", nargs='+', help="public keys for encryption (paths)",  metavar="KEYS")
        parser.add_argument("-f", "--file", dest="file", help="output file (with extension)", metavar="FILE")
        parser.add_argument("-I", "--ignore", help="ignore if secret already present", action='store_true')
        parser.add_argument("-F", "--force", help="force recreate secret", action='store_true')
        parser.add_argument("-c", "--content",dest="content", help="set encrypted file content", metavar="CONTENT")
        parser.add_argument("-u", "--user",dest="user", help="owner of the encrypted file", metavar="USER")
        parser.add_argument("-g", "--group",dest="group", help="usergroup of the encrypted file (if different from the group of owner)", metavar="GROUP")
        args = parser.parse_args()

        # adapt/parse the arguments
        outfile = args.file
        if outfile == None :
            print( colored("Error: ", Colors.FAIL) + "no output path (-f) provided")
            parser.print_help()
            exit(1)
        keys = args.keys
        if len(keys) < 1 :
            print( colored("Error: ", Colors.FAIL) + "no key provided")
            parser.print_help()
            exit(1)

        # try decrypt file :
        if  fileExists(outfile) :
            if args.force == True:
                print( colored("Warning: ", Colors.WARNING) + "removing already present secret")
                removeFile(outfile)
            elif args.ignore == True:
                print( colored("Skipped: ", Colors.OKCYAN) + "File already present")
                exit(0)
            else :
                print( colored("Error: ", Colors.FAIL) + "Secret file already present")
                exit(1)

        # WARNING : ENCRPYTED DATA IS VISIBLE
        content = args.content
        if content == None :
            print(f"enter content for {colored(outfile, Colors.BOLD)} :\n")
            content = input()

        # create and set the output file
        encrypt(keys, outfile, content)
        if args.user != None :
            setOwnership(outfile, args.user, args.group)

    # handle exceptions :
    except KeyboardInterrupt :
        print( colored("Fail: ", Colors.FAIL) + "user interrupted the process, exiting")
    except PermissionError :
        print( colored("Fail: ", Colors.FAIL) + "cannot encrypt secret, permission denied (try again with sudo)")
    except EOFError :
        print( colored("Fail: ", Colors.FAIL) + "cannot encrypt secret, ran without input")
    except Exception as E :
        print( colored("Fail: ", Colors.FAIL) + f" {E}")
    else :
        print( colored("Success: ", Colors.OKGREEN) + "secret is encrypted with ssh key")
        exit(0)
    finally:
        print( colored("Fail: ", Colors.FAIL) + "failed to encrypt secret with ssh key")
        exit(1)
