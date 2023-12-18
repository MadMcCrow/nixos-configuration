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


def nixage_decrypt(infile, outfile, keys, force, ignore) :
    """
        Decrypt a age secret to a normal file
    """
    # decrypt to memory :
    result = decrypt(keys, infile)
    # compare with already decrypted file :
    if  fileExists(outfile) :
        existing = readFile(outfile)
        if existing == result :
            note("File already decrypted")
            return
        elif force != True :
                error("already present file differs from decrypted secret")
                raise FileExistsError
        else :
            removeFile(outfile)
            # continue
    # write decrypted secret
    writeFile(outfile, result)



def nixage_encrypt(infile, outfile, keys, force, ignore) :
    """
        encrypt a normal file to an age secret
    """
    # try decrypt file :
    if fileExists(outfile) :
        if force :
           warning("removing already present secret")
           removeFile(outfile)
        elif ignore :
            note("File already present, skipping")
            return
        else :
            error("Secret file already present")
            raise FileExistsError
    # WARNING : ENCRPYTED DATA IS VISIBLE
    if infile != None :
        content = readFile(infile)
    else :
        note(f"enter content for {bold(outfile)}:\n")
        content = input()
    # create and set the output file
    encrypt(keys, outfile, content)


# Main Program :
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
       
        #  add crypt parameters
        parser.add_argument(dest="mode", nargs=1, metavar="MODE", choices = ["encrypt", "decrypt"], help="mode for nixage")
        parser.add_argument("-i", "--input", dest="input",  help="input file (full path)", metavar="IN",   required = True)
        parser.add_argument("-k", "--keys",  dest="keys", nargs='+', help="ssh keys path",  metavar="KEY", required = True)
       
        # General options
        parser.add_argument("-I", "--ignore", dest="ignore", help="ignore errors",                 action='store_true')
        parser.add_argument("-F", "--force",  dest="force",  help="force action (recreate files)", action='store_true')
        parser.add_argument("-S", "--silent", dest="silent", help="silent, only output errors",    action='store_true')

        # file output options
        parser.add_argument("-o", "--output", dest="output", help="output file (with extension)", metavar="OUT", required = True)
        parser.add_argument("-u", "--user",dest="user", help="owner of the encrypted file", metavar="USER")
        parser.add_argument("-g", "--group",dest="group", help="usergroup of the encrypted file (if different from the group of owner)", metavar="GROUP")

        # start parser !
        args = parser.parse_args()

        # adapt/parse the arguments
        infile  = args.input
        outfile = args.output
        keys = list(set(args.keys))
        mode = args.mode
        set_silent(args.silent)

        # perform the correct action
        {
            'decrypt' : nixage_decrypt,
            'encrypt' : nixage_encrypt
        }.get(mode)(infile, outfile, keys, args.force, args.ignore)

        # set ownership of created file
        if args.user != None :
            setOwnership(outfile, args.user, args.group)

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
        error(f"Unhandled Error : {E}")
    else :
        success("secret is encrypted with ssh key")
        exit(0)
    finally :
        error("failed to encrypt secret with ssh key")
        exit(1)


        
