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


def encrypt(keys : list, content : str) :
    """
        We import  the public key and encrypt a string with it
        TODO :
            [ ] - support passphrases
    """
    # read key:
    note(f"""encrypting {bold(outfile)} with {bold(f'[{",".join([f"{x}" for x in keys])}]')}:\n""")
    encryptor_keys = []
    for key in keys:
        encryptor_keys.extend(resolve_public_key(key))
    # create a buffer :
    out = io.BytesIO()
    try : 
        with Encryptor(encryptor_keys,out) as encryptor :
            c = str(content).encode("utf-8")
            encryptor.write(c)
    except Exception as E:
        out.flush()
        raise E
    else :
        return out.getvalue()


def decrypt(keys : list, encrypted : bytes) :
    """
        We import the private key and open the file
        TODO :
            [ ] - support passphrase
    """
    rsa_keys = []
    for key in keys:
        rsa_keys.append(load_ssh_private_key(key))
    inbuffer = io.BytesIO(encrypted)
    try :
        with Decryptor(rsa_keys, inbuffer) as decryptor:
            out = decryptor.read()
        return out.decode('utf8')
    except Exception as E:
        inbuffer.flush()
        raise E