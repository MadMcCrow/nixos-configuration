#!/usr/bin/env python

# Python imports
import os
import argparse
from sys import exit;

# ssh-keygen equivalent
from Crypto.PublicKey import RSA as rsa

# local modules
from colors import colored, Colors

# generate a private key
def genKey( key:str , path : str) :
    """
        We create a key pair and write a public and a private key
        TODO :
            [ ] - support passphrase
    """
    print(f"generating ssh key pair : {colored(key, Colors.BOLD)}  at {colored(path, Colors.BOLD)}:\n")
    rsa_key = rsa.generate(2048)
    with open(path, 'wb') as private_file:
        os.chmod(path, _secretPermission)
        private_file.write(rsa_key.exportKey('PEM'))
    with open(f"{path}.pub", 'wb') as public_file:
        os.chmod(path, _secretPermission)
        public_file.write(rsa_key.public_key().exportKey('OpenSSH'))

def updateKey(key : str, path : str) :
    """
        We import the private key and ask for a public key
        TODO :
            [ ] - support passphrase
    """
    print(f"updating ssh key (creating public key) for {colored(key, Colors.BOLD)}:\n")
    with open(path, 'r') as key_file :
        key_text = key_file.read()
        rsa_key = rsa.import_key(key_text)
    assert rsa_key.has_private()
    with open(f"{path}.pub", 'wb') as public_file:
        os.chmod(path, _secretPermission)
        public_file.write(rsa_key.public_key().exportKey('OpenSSH'))

# main implementation for commandline
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
        parser.add_argument("-k", "--key",  dest="key", help="key name",  metavar="KEY")
        parser.add_argument("-p", "--public-key",  dest="pubkey", help="public key to use (file)",  metavar="PUBKEY")
        parser.add_argument("-P", "--private-key", dest="prvkey", help="private key to use (file)", metavar="PRVKEY")
        args = parser.parse_args()

        # adapt/parse the arguments
        outfile = args.file
        if outfile == None :
            print( colored("Error: ", Colors.FAIL) + "no file provided")
            parser.print_help()
            exit(1)

        if args.key == None and (args.pubkey == None or args.prvkey == None) :
            print( colored("Error: ", Colors.FAIL) + "no key provided")
            parser.print_help()
            exit(1)

        key = args.key
        if key == None :
            key = args.prvkey

        pubkey = args.pubkey
        if pubkey == None :
            pubkey = f"{key}.pub"

        prvkey = args.prvkey
        if prvkey == None :
            prvkey = key

        content = args.content

        # missing private key :
        if not os.path.isfile(prvkey) :
            print( colored("Error: ", Colors.FAIL) + "Missing private key")
            removeFile(pubkey)
            genKey(key, prvkey)

        # missing public or private key
        if not os.path.isfile(pubkey) :
            print( colored("Warning: ", Colors.WARNING) + "Missing public key")
            updateKey(key, prvkey)


    except KeyboardInterrupt :
        print( colored("Fail: ", Colors.FAIL) + "user interrupted the process, exiting")
        exit(1)

    except PermissionError :
        print( colored("Fail: ", Colors.FAIL) + "cannot write ssh key, permission denied (try again with sudo)")
        exit(1)

    else:
        print( colored("Success: ", Colors.OKGREEN) + "SSH keys are present on the system")
        exit(0)
