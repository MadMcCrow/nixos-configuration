#!/usr/bin/env python
#
#   age_crypt.py :
#       functions to encrypt and decrypt with age
#

# Python imports
import os
import argparse
import errno

# ssh-keygen equivalent
from Crypto.PublicKey import RSA as rsa
# pyage (replace age command line)
from age.keys.rsa import RSAPublicKey, RSAPrivateKey
from age.keyloader import resolve_public_key, load_ssh_private_key
from age.file import Encryptor, Decryptor


# our modules imports :
from files import *
from colors import *

# encrypt a prompt from user to a file
def encrypt(keys : list, outfile : str, content : str) :
    """
        We import  the public key and encrypt the file with it
        TODO :
            [ ] - support passphrases
    """
    # read key:
    print(f"""encrypting {colored(outfile, Colors.BOLD)} with {colored(f'[{",".join([f"{x}" for x in keys])}]', Colors.BOLD)}:\n""")
    encryptor_keys = []

    ## Old method :
    #for key in keys:
    #   with open(key, 'r') as key_file:
    #    try :
    #      key_text = key_file.read()
    #      rsa_key = rsa.import_key(key_text)
    #    except ValueError : # ValueError: RSA key format is not supported
    #      warning("using public key as-is")
    #      public_keys.append(key_text)
    #    else :
    #      public_keys.append(rsa_key.public_key().exportKey('OpenSSH') if rsa_key.has_private() else rsa_key.exportKey('OpenSSH'))
    #encryptor_keys = list(set([RSAPublicKey.from_ssh_public_key(p) for p in public_keys]))

    for key in keys:
        encryptor_keys.extend(resolve_public_key(key))

    try :
        os.makedirs(os.path.dirname(outfile), exist_ok=True)
        with open(outfile, 'wb') as out :
            with Encryptor(encryptor_keys,out) as encryptor :
                c = str(content).encode("utf-8")
                encryptor.write(c)
    except Exception as E:
        removeFile(outfile)
        raise E


def decrypt(keys : list, inFile : str) :
    """
        We import the private key and open the file
        TODO :
            [ ] - support passphrase
    """
    # old method:
    # rsa_keys = []
    #for key in keys:
    #    with open(key, 'r') as key_file:
    #        key_text = key_file.read()
    #        rsa_keys.append(rsa.import_key(key_text))
    # decryptor_keys = list(set([RSAPrivateKey.from_pem(r.exportKey('PEM')) for r in rsa_keys]))
    
    rsa_keys = []
    for key in keys:
        rsa_keys.append(load_ssh_private_key(key))
    
    try :
        contentFile = open(inFile, 'rb')
    except FileNotFoundError :
        print(f"cannot find file {inFile}")
        raise FileNotFoundError
    else :
        with Decryptor(rsa_keys, contentFile) as decryptor:
            out = decryptor.read()
        contentFile.close
        return out.decode('utf8')