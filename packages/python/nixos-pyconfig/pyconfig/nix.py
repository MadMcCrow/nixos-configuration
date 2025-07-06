#!/usr/bin/python
#
# Nix expression to evaluate

# python standard inputs
import asyncio
import json
from typing import Any

# pycall
import pycall


class Nixpath() :
    """
        simple class to handle paths to flake or nix config files
    """

    def __init__(self, instr : str = "") :
        super().__init__()
        # perform fixups :
        for p in ['github', 'gitlab'] :
            instr = instr.replace(f'https://{p}.com/', f'{p}:')
        instr = instr.replace('/flake.nix', '')
        if not instr.endswith('.nix') :
            # a flake can be referenced by output directly
            if not instr.startswith('.#') :
                instr = '.#' + instr
        # store the evalkey
        self._path = instr

    def nix_eval(self) -> str:
        if self.is_flake() :
            Flake(self).find_output(self._path.split('#')[1])
        else :
            apply = "'x: x {pkgs = import <nixpkgs> {};}'"
            return f"nix eval --file '{self._path}'  --json --apply {apply}"

    def is_flake(self) :
        if '#' in self._evalkey : 
            return True
        if self._evalkey.endswith('flake.nix'):
            return True
        return False



class NixValue() :
    """
        wrapper around futures and values to avoid manipulating futures
    """

    _value = None

    def __init__(self, option):
        self._option = option
        self._future = 
        self._future.add_done_callback(self._on_result)

    def _on_result(self, future) :
        self._value = json.loads(str(future.result()))

    def value(self) -> Any :
        if not self._future.done() : 
            loop = self._future.get_loop()
            self._value = loop.run_until_complete(self._future)
        return self._value
           
    def __str__(self) :
        return str(self.value())

    async def async_nix_eval(self) :
        cmd = self._cmd(self.option)
        if self._nix_features() is not None :
            cmd += f" --extra-experimental-features '{self._nix_features()}'"
        if self._nix_apply() is not None :
            cmd += f" --apply '{self._nix_apply()}'"
        return await pycall.async_run(cmd)
    
        

    
        