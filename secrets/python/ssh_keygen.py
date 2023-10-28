#!/usr/bin/env python
#
#   ssh_keygen : a script responsible for creating ssh keys
#                also a lib
#

# Python imports
import os
import argparse
from sys import exit;

# ssh-keygen equivalent
from Crypto.PublicKey import RSA as rsa

# local modules
from colors import *
from files import *


# constants :
_keyPermission = "600"

# generate a private key
def genPrivateKey(path:str) :
    """
        We create a private key
    """
    rsa_key = rsa.generate(2048)
    writeFile(path,rsa_key.exportKey('PEM'), True)
    setPermission(path, _keyPermission)


def genPublicKey(private_path : str, public_path : str) :
    """
        We import the private key and create a public key
    """
    rsa_key = rsa.import_key(readFile(private_path))
    assert rsa_key.has_private()
    if not fileExists(public_path):
        writeFile(public_path, rsa_key.public_key().exportKey('OpenSSH'), True)
    setPermission(public_path, _keyPermission)


# main implementation for commandline
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
        parser.add_argument("-K", "--public-key",  dest="pubkey", help="public key to use (file)",  metavar="PUBKEY")
        parser.add_argument("-P", "--private-key", dest="prvkey", help="private key to use (file)", metavar="PRVKEY")
        parser.add_argument("-F", "--force", dest="force", help="force recreate key pair", action='store_true')
        parser.add_argument("-s", "--silent", dest="silent", help="limit verbosity to error and success", action='store_true')
        args = parser.parse_args()

        # adapt/parse the arguments
        prvkey = args.prvkey
        pubkey = args.pubkey
        if prvkey == None :
            error("no private key provided")
            if not args.silent :
                parser.print_help()
            exit(1)
        if pubkey == None :
            pubkey = f"{prvkey}.pub"

        # private key :
        if (not fileExists(prvkey)) or args.force :
            removeFile(pubkey)
            if not args.silent :
                print(f"generating ssh private key : {colored(prvkey, Colors.BOLD)}")
            genPrivateKey(prvkey)

        # public key :
        if not args.silent:
            print(f"updating ssh public key: {colored(pubkey, Colors.BOLD)}")
        genPublicKey(prvkey)

    except KeyboardInterrupt :
        error("user interrupted the process, exiting")
        exit(1)
    except PermissionError :
        error("cannot write ssh key, permission denied (try again with sudo)")
        exit(1)
    except Exception as E :
        error(f"unhandled error {E}")
        exit(1)
    else:
        success("SSH keys ${args.prvkey} generated")
        exit(0)
