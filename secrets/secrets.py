#!/usr/bin/env python

# We use python for readability and speed compared to bash
# this will be compiled

# TODO : use pyage (import age ) to avoid calling age in a subprocess

import subprocess
import shlex
import os
import argparse
import io

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


def fileExists(path : str) :
    try :
        return os.path.exists(path)
    except :
        return False

def removeFile(path : str) :
    try :
        os.remove(path)
    except:
        pass

# wrapper around subprocess.run
def runShellCommand( command , text = None) :
    if text ==  None  or text == "" :
        return subprocess.run(shlex.split(command))
    else :
        StdinText = io.StringIO(text)
        return subprocess.run(shlex.split(command), input = stdinText, text = True, encoding='utf8')        

# generate a ssh key
def genKey( key:str , path : str) :
    # call ssh keygen
    runShellCommand(f"ssh-keygen -C {key} -f {path}  -q")


# encrypt a prompt from user to a file
def encrypt(pubKey : str, outFile : str) :
    print(f"enter content for {colored(outFile, Colors.BOLD)} :\n")
    content = input()
    runShellCommand(f"age --encrypt -R {pubKey} -o {outFile}", content )

# try to decrypt a file
def decrypt(prvKey : str, inFile : str) :
    result = runShellCommand(f"age --decrypt -i {prvKey}  {inFile}")
    if result != 0 :
        return False
    else :
        return True


try : 
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--key",  dest="key", help="key name",  metavar="KEY")
    parser.add_argument("-p", "--public-key",  dest="pubkey", help="public key to use (file)",  metavar="PUBKEY")
    parser.add_argument("-P", "--private-key", dest="prvkey", help="private key to use (file)", metavar="PRVKEY")
    parser.add_argument("-f", "--file", dest="file", help="output file (with extension)", metavar="FILE")
    parser.add_argument("-F", "--force", dest="force", help="force recreate secret", metavar="FORCE")
    args = parser.parse_args()

    if args.file == None :
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


    # do not have a prv key
    if not fileExists(prvkey) :
        removeFile(pubkey)
        genKey(key, prvkey)

    if not fileExists(prvkey) :
        removeFile(pubkey)
        genKey(key, prvkey)

    # cannot decrypt file : delete all
    if not decrypt(prvkey, args.file) :
        removeFile(pubkey)
        removeFile(prvkey)
        removeFile(args.file)
        genKey(key, prvkey)
    # skip : nothing to do
    elif args.force == None :
        print( colored("SKipped: ", Colors.OKCYAN) + "File already encrypted")
        exit(0)

    # key is valid :
    encrypt(pubkey, args.file)
    if decrypt(prvkey, args.file) :
        print( colored("Success: ", Colors.OKGREEN) + "secret is encrypted with ssh key")
        exit(0)
    else :
        print( colored("Fail: ", Colors.FAIL) + "failed to encrypt secret with ssh key")
        exit(0)

except KeyboardInterrupt :
    print( colored("Fail: ", Colors.FAIL) + "user interrupted the process, exiting")
    exit(1)