#!/usr/bin/python
#
# config.py : parse a nixos config :

# python default imports
import json
import sh

def parse_config(value : str, hostname : str = "", flake : str = ".") :
    nix_config = f"{flake}#nixosConfigurations.{hostname}.config.{value}"
    nix_output = sh.exec(f"nix eval -v -L {nix_config} --json",
        f"evaluating {nix_config}")
    nix_dict = json.loads(nix_output)
    return nix_dict