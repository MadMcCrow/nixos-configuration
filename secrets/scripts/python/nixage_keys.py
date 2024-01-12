#!/usr/bin/env python
#
#   nixage_keys : a script responsible for creating ssh keys
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

global silent

# constants :
_keyPermission = "600"

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

# Main Program :
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
        set_silent(args.silent)

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
            note(f"generating ssh private key : {bold(prvkey)}")
            genPrivateKey(prvkey)

        # public key :
        note(f"updating ssh public key: {bold(pubkey)}")
        genPublicKey(prvkey, f"{prvkey}.pub")

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
        success(f"SSH keys {bold(prvkey)} generated")
        exit(0)