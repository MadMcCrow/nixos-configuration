#!/usr/bin/env python

# We use python for readability and speed compared to bash
# this will be compiled


import subprocess
import shlex
import os
import argparse
import io

from Crypto.PublicKey import RSA as rsa # ssh-keygen equivalent
import age as age                  # pyage (replace age command line)


# constants :
_secretPermission = 0o600

# color output
class Colors:
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def colored(text : str, color ) :
    return '\0'.join([color, text, Colors.ENDC])

def removeFile(path) :
    try :
        os.remove(path)
    except FileNotFoundError :
        pass

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
    

# encrypt a prompt from user to a file
def encrypt(key : str, outfile : str, content : str) :
    """
        We import  the public key and encrypt the file with it
        TODO : 
            [ ] - support passphrase
            [ ] - support list of keys
    """
    # read key:
    print(f"encrypting {colored(outfile, Colors.BOLD)} with {colored(key, Colors.BOLD)}:\n")
    public_key = ""
    with open(key, 'r') as key_file:
        try :
            key_text = key_file.read()
            rsa_key = rsa.import_key(key_text)
        except ValueError : # ValueError: RSA key format is not supported
            print("using public key as-is")
            public_key = key_text
        else :
            public_key = rsa_key.public_key().exportKey('OpenSSH') if rsa_key.has_private() else rsa_key.exportKey('OpenSSH')
    # make a list of keys
    # write to encrypted file
    with age.Encryptor([public_key], outfile) as encryptor:
        encryptor.write(content)


def decrypt(key : str, inFile : str) :
    """
        We import the private key and ask for a public key
        TODO : 
            [ ] - support passphrase
    """
    # read key:
    with open(key, 'r') as key_file:
        key_text = key_file.read()
        rsa_key = rsa.import_key(key_text)
    # read encrpyted content
    try : 
        contentFile = open(inFile, 'r')
    except FileNotFoundError :
        return None
    else :
        with age.Decryptor([rsa_key.exportKey('PEM')], inFile) as decryptor:
            return decryptor.read()

# main implementation for commandline
if __name__ == "__main__" :
    try :
        parser = argparse.ArgumentParser()
        parser.add_argument("-k", "--key",  dest="key", help="key name",  metavar="KEY")
        parser.add_argument("-p", "--public-key",  dest="pubkey", help="public key to use (file)",  metavar="PUBKEY")
        parser.add_argument("-P", "--private-key", dest="prvkey", help="private key to use (file)", metavar="PRVKEY")
        parser.add_argument("-f", "--file", dest="file", help="output file (with extension)", metavar="FILE")
        parser.add_argument("-F", "--force", help="force recreate secret", action='store_true')
        args = parser.parse_args()


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



        # missing private key :
        if not os.path.isfile(prvkey) :
            print( colored("Error: ", Colors.FAIL) + "Missing private key")
            removeFile(pubkey)
            genKey(key, prvkey)

        # missing public or private key
        if not os.path.isfile(pubkey) :
            print( colored("Warning: ", Colors.WARNING) + "Missing public key")
            updateKey(key, prvkey)

        # cannot decrypt file :
        if  os.path.exists(outfile) :
            if decrypt(prvkey, outfile) == None :
                print( colored("Error: ", Colors.FAIL) + "Cannot decrypt with private key")
                if args.force == True:
                    removeFile(outfile)
            # skip : nothing to do
            elif args.force != True :
                print( colored("SKipped: ", Colors.OKCYAN) + "File already encrypted")
                exit(0)

        # key is valid :
        # input :
        # WARNING : ENCRPYTED DATA IS VISIBLE 
        print(f"enter content for {colored(outfile, Colors.BOLD)} :\n")
        content = input()
        encrypt(pubkey, outfile, content)
        if decrypt(prvkey, outfile) == content :
            print( colored("Success: ", Colors.OKGREEN) + "secret is encrypted with ssh key")
            exit(0)
        else :
            print( colored("Fail: ", Colors.FAIL) + "failed to encrypt secret with ssh key")
            exit(0)

    except KeyboardInterrupt :
        print( colored("Fail: ", Colors.FAIL) + "user interrupted the process, exiting")
        exit(1)
