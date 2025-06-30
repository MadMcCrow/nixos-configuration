#!/usr/bin/python
#
# Nix expression to evaluate

# python standard inputs
from collections import UserDict
import asyncio
import json
import sys
from threading import Lock

# pycall
import pycall

def __subdict(d , k : str) -> dict :
        try: 
            return d[k]
        except KeyError:
            d[k] = None
            return d[k]


class Nixpath(str) :
    """
        simple class to handle paths to flake or nix config files
    """

    def __init__(self, instr : str = "") :
        super().__init__()
        self = instr
        # perform fixups :
        for p in ['github', 'gitlab'] :
            self.replace(f'https://{p}.com/', f'{p}:')

    def flakehost(self) : 
        return self.split('#')[1]

    def flakepath(self) :
        return self.split('#')[0]

    def isFlake(self) :
        if '#' in self : 
            return True
        if self.endswith('flake.nix'):
            return True
        return False

    def config(self) :
        raise NotImplementedError("config support is not implemented yet")
        # TODO : improve config workflow
        return self

class NixValue() :
    """
        wrapper around futures and values to avoid manipulating futures
    """


    def __init__(self, future : asyncio.Future ):
        self._value = None
        self._future = future
        self._future.add_done_callback(self._on_result)
        # asyncio.get_event_loop().run_in_executor

    def _on_result(self, future) :
        self._value = future.result()
        self._future = None

    def get(self) :
        if self._future is not None :
            result = asyncio.get_event_loop().run_until_complete(self._future)
            self._value = result
            self._future = None
            return result
        if self._value is not None :
            return self._value
        raise ValueError("Invalid NixValue")
        
    def __str__(self) : 
        return str(self.get())
        


class NixExpression():
    '''
        meta class to retrieve data out of nix evaluation
    '''
    __values : dict = {}    # results
    _expression : Nixpath   # the nix expression we're representing
    _tasks = []             # list of running tasks

    def __init__(self, uri : str | Nixpath) :
        if type(uri) is str :
           self._expression = Nixpath(uri)
        else :
            self._expression = uri
    
    @property
    def _values(self) :
        if self._expression not in self.__class__.__values :
            self.__class__.__values[self._expression] = {}
        return self.__class__.__values[self._expression]

    @_values.setter
    def _values(self, value) -> None :
        self.__class__.__values[self._expression].update(value)

    def add_nix_eval(self, option) :
        loop = asyncio.get_event_loop()
        fut = loop.create_task(self.async_nix_eval(option))
        nixvalue = NixValue(future=fut)
        return nixvalue

    def __getitem__(self,key : str) :
            subkeys = key.split('.')
            sub = self._values
            for sk in subkeys[:-1] :
                sub = __subdict(sub, sk)
            try : 
                return sub[subkeys[-1]]
            except KeyError :
                sub[subkeys[-1]] = self.add_nix_eval(key)
                return sub[subkeys[-1]]


    def __setitem__(self, key, item) -> None:
        raise RuntimeError("NixExpression cannot be set")

    async def async_nix_eval(self, option : str) :
        # write nix eval command
        cmd = self._cmd()
        if self._nix_features() is not None :
            cmd += f" --extra-experimental-features {self._nix_features()}"
        if self._nix_apply() is not None :
            cmd += f" --apply {self._nix_apply()}"
        # make the call
        result = await pycall.async_run(cmd)
        print(f'result is {str(result)}')
        return json.loads(str(result))


    def _cmd(self) -> str :
        return "nix eval -v -L '{}' --json"

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