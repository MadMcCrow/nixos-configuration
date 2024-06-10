#!/bin/python
description = """
    install script that checks that nix is properly installed,  
    that experimental nix features are enabled, and then 
    installs the latest configuration for your MacOS device

    it also works as an updater, and almost without cloning 
    the repo in the first place (you need to have installed
    nix darwin at least once before )
"""

# imports:
from os import path
from shutil import move, copy, which
from urllib.request import urlopen
from hashlib import sha3_256

def backup() :
    """
        creates backups :
            /etc/bashrc
            /etc/zshrc
            /etc/bash.bashrc
    """
    for rc in ["bashrc", "zshrc", "bash.bashrc"] :  
        backup=f"etc/{rc}.backup-before-nix"
        if  path.exists(backup) :
            print(f"backup already exists, skipping")
        else : 
            copy( f"/etc/{rc}", backup)
    

def revertBackup() :
    """
        revert backups :
            /etc/bashrc
            /etc/zshrc
            /etc/bash.bashrc
    """
    for rc in ["bashrc", "zshrc", "bash.bashrc"] :  
        backup=f"etc/{rc}.backup-before-nix"
        if  path.exists(backup) :
            print(f"reverting backup {rc}")
            move(backup, f"/etc/{rc}")


def install_nix() :
    if which("nix") is not None :
        print("nix already installed, skipping")
    else :
        with urlopen("https://nixos.org/nix/install") as response:
            body = response.read()
        expected_hash = 'e7594cafe72b43b36b83e6241a8389e979c1b28a8f0a20c2673f9d0be721a4e2'
        hs = sha3_256(body).hexdigest()
        if hs != expected_hash :
            raise ValueError("downloaded nix install script has incorrect hash")
        