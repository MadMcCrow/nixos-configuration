#!/usr/bin/python
#
# Collection of function for dealing with flakes

# standard python
from os.path import dirname

#ours :
from .nix import Nixpath
from .uniquedict import UniqueDict

class Flake(UniqueDict) :


    def __init__(self) -> None:
        pass

    def find_output(self, output) -> str :
        self._values()

    async def async_nix_eval(self, option : str) :
        cmd = self._cmd(option)
        if self._nix_features() is not None :
            cmd += f" --extra-experimental-features '{self._nix_features()}'"
        if self._nix_apply() is not None :
            cmd += f" --apply '{self._nix_apply()}'"
        return await pycall.async_run(cmd)