# perform the nix installation
#!/usr/bin/python
import os
import shutil 
import subprocess
import stat
from urllib.request import urlretrieve

def revert(path) : 
    backpath = f'{path}.backup-before-nix'
    if os.path.exists(backpath) :
        os.rename(backpath, path)
    else :
        print(f"warning: no 'backup-before-nix' found for {path}")


def install_nix() :
    if shutil.which('nix') is None :
        for p in ['bashrc', 'zshrc', 'bashrc'] : 
            revert(f'/etc/{p}')
        install_script = './install.sh'
        urlretrieve('https://nixos.org/nix/install', './install.sh')
        os.chmod(install_script, stat.S_IXUSR | stat.S_IXGRP)
        rc = subprocess.call(install_script)
    
    # make sure experimental features are enabled :
    features="experimental-features = nix-command flakes"
    nixconfig = os.path.expanduser('~/.config/nix')
    os.makedirs(os.path.dirname(nixconfig), exist_ok=True)
    if not os.path.exists(nixconfig) :
        with open(nixconfig,'w') as f :
            f.write(features)
    else:
        with open(nixconfig, 'r+') as f:
            if not features in f.read() :
                f.write(features)