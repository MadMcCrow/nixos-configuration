#!/usr/bin/python
#
# Evaluate a nixos-configuration, whether from file or from flake output

# python
import json
import asyncio
from threading import Lock

# pycall
import pycall

# ours
from .flake import Flake
from .nix import Nixpath, NixExpression

class Configuration(NixExpression) :

    def _cmd(self) -> str :
        return "nix eval -v -L '{}' --json"

    def _nix_apply(self) -> str|None :
        pass
    
    def _nix_features(self) -> str|None : 
        if self._expression.isFlake() :
            return "nix-command flakes"
        