#!/usr/bin/env python

# Python imports
import os
import argparse
from sys import exit;
from pwd import getpwnam
from grp import getgrnam

# ssh-keygen equivalent
from Crypto.PublicKey import RSA as rsa
# pyage (replace age command line)
from age.keys.rsa import RSAPublicKey, RSAPrivateKey
from age.file import Encryptor, Decryptor

# local modules
from colors import colored, Colors
from ssh_keygen import updateKey, genKey


def removeFile(path) :
    try :
        os.remove(path)
    except FileNotFoundError :
        pass

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
    Keys = [RSAPublicKey.from_ssh_public_key(public_key)]
    try :
        with open(outfile, 'wb') as out :
            with Encryptor(Keys,out) as encryptor :
                c = str(content).encode("utf-8")
                encryptor.write(c)
    except Exception as E:
        removeFile(outfile)
        raise E


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
        contentFile = open(inFile, 'rb')
    except FileNotFoundError :
        return None
    else :
        with Decryptor([RSAPrivateKey.from_pem(rsa_key.exportKey('PEM'))], contentFile) as decryptor:
            out = decryptor.read()
        contentFile.close
        return out.decode('utf8')

def set_ownership(path: str, owner: str, group :str = None) -> bool:
    """
        Set owner ship of the path to the wanted user and group
        if no group is provided, we default to the user's group
    """
    if owner == None :
        return False
    uid = getpwnam(owner).pw_uid
    if group != None :
        gid = getgrnam(group).gr_gid
    else :
        gid = getpwnam(owner).pw_gid
    stats = os.stat(path)
    os.chown(path,uid,gid)
    return (stats.st_uid != uid or stats.st_gid != gid)


# main implementation for commandline
if __name__ == "__main__" :
    try :
        # argument parser :
        parser = argparse.ArgumentParser()
        parser.add_argument("-k", "--key",  dest="key", help="key name",  metavar="KEY")
        parser.add_argument("-p", "--public-key",  dest="pubkey", help="public key to use (file)",  metavar="PUBKEY")
        parser.add_argument("-P", "--private-key", dest="prvkey", help="private key to use (file)", metavar="PRVKEY")
        parser.add_argument("-f", "--file", dest="file", help="output file (with extension)", metavar="FILE")
        parser.add_argument("-F", "--force", help="force recreate secret", action='store_true')
        parser.add_argument("-c", "--content",dest="content", help="set encrypted file content", metavar="CONTENT")
        parser.add_argument("-o", "--owner",dest="owner", help="owner of the encrypted file", metavar="OWNER")
        parser.add_argument("-g", "--group",dest="group", help="usergroup of the encrypted file (if different from the group of owner)", metavar="GROUP")
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

        # try decrypt file :
        if  os.path.exists(outfile) :
            result = decrypt(prvkey, outfile)
            # fail to decrypt
            if result == None :
                if args.force == True:
                    removeFile(outfile)
                else:
                    print( colored("Error: ", Colors.FAIL) + "Cannot decrypt with private key")
                    exit(1)
            # wrong content
            elif content != None and result != content :
                if args.force == True:
                    removeFile(outfile)
                else :
                    print( colored("Error: ", Colors.FAIL) + "Content differs from commandline argument")
                    exit(1)
            # skip : nothing to do
            elif args.force != True :
                print( colored("input content: ", Colors.OKCYAN)       + str(content))
                print( colored(f"{outfile} content: ", Colors.OKCYAN)  + str(result))
                print( colored("Skipped: ", Colors.OKCYAN) + "File already encrypted")
                if set_ownership(outfile, args.owner, args.group)  :
                    print( colored("Success: ", Colors.OKGREEN) + "Ownership of encrypted file changed")
                exit(0)

        # key is valid :
        # input :
        # WARNING : ENCRPYTED DATA IS VISIBLE
        if content == None :
            print(f"enter content for {colored(outfile, Colors.BOLD)} :\n")
            content = input()

        encrypt(pubkey, outfile, content)
        if decrypt(prvkey, outfile) == content :
            print( colored("Success: ", Colors.OKGREEN) + "secret is encrypted with ssh key")
            if set_ownership(outfile, args.owner, args.group)  :
                    print( colored("Success: ", Colors.OKGREEN) + f"Ownership of encrypted set to {args.owner}{args.group}")
            exit(0)
        else :
            print( colored("Fail: ", Colors.FAIL) + "failed to encrypt secret with ssh key")
            exit(1)
    # handle exceptions :
    except KeyboardInterrupt :
        print( colored("Fail: ", Colors.FAIL) + "user interrupted the process, exiting")
        exit(1)
    except PermissionError :
        print( colored("Fail: ", Colors.FAIL) + "cannot encrypt secret, permission denied (try again with sudo)")
        exit(1)
    except EOFError :
        print( colored("Fail: ", Colors.FAIL) + "cannot encrypt secret, ran without input")
        exit(1)
    except :
        print( colored("Fail: ", Colors.FAIL) + "Unknown error")
        exit(1)
    else :
        print( colored("Success: ", Colors.OKGREEN) + "nothing to do")
        exit(0)
