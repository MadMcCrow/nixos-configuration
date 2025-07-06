#!/usr/bin/python
#
# Evaluate a nixos-configuration, whether from file or from flake output

# ours
from .nix import Nixpath, NixValue


class Configuration() :

  '''
        meta class to retrieve data out of nix evaluation
    '''
    __values : dict = {}    # results
    _expression : Nixpath   # the nix expression we're representing
    _tasks = []             # list of running tasks

    def __init__(self, uri : str | Nixpath) :
        if isinstance(uri, str):
           self._expression = Nixpath(uri)
        elif isinstance(uri, Nixpath):
            self._expression = uri
    
   
    def add_nix_eval(self, option) :
        loop = asyncio.get_event_loop()
        return NixValue(loop.create_task(self.async_nix_eval(option)))


    async def async_nix_eval(self, option : str) :
        cmd = self._cmd(option)
        if self._nix_features() is not None :
            cmd += f" --extra-experimental-features '{self._nix_features()}'"
        if self._nix_apply() is not None :
            cmd += f" --apply '{self._nix_apply()}'"
        return await pycall.async_run(cmd)
    
        

    def _cmd(self, option) -> str :
        return f"nix eval -v -L '{self._expression}' --json"

    def _nix_apply(self) -> str|None :
        '''
            nix code to apply to the evaluation
        '''
        pass

    def _nix_features(self) -> str|None : 
        '''
            extra features to enable for the evaluation
        '''
        pass