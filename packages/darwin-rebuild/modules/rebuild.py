# rebuild the nix-darwin generation
#!/usr/bin/python
import socket
import sh

def switch(host = '', flake = '') : 
    if host == '' :
        host= socket.gethostname().removesuffix('.local')
    # local build or call as script :
    if flake == '' :
        flake = sh.git("rev-parse --show-toplevel")

    p = sh.nix(f'build {flake}#darwinConfigurations.{host}.system')
    p.wait()

    './result/sw/bin/darwin-rebuild switch --flake ".#$HOST"'