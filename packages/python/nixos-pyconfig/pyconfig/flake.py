#!/usr/bin/python
#
# Collection of function for dealing with flakes

# standard python
from os.path import dirname

#ours :
from .nix import NixExpression, Nixpath

class Flake(NixExpression) :

    def cmd(self) -> str :
        return "nix flake show -v -L '{}' --json"