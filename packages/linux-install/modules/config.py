#!/usr/bin/python
#
# config.py : parse a nixos config :

# python default imports
import json # for load and dumps
from time import sleep
from sys import exit

_NL = '\n'

class Config :

    def __init__(self,  hostname : str, flake : str = ".") :
        self.hostname = hostname
        self.flake = flake
        self._dict = dict()
        self._command = None
        self.load()
        atexit.register(self.dump)


    def append(self, attribute, value) :
         self._dict[attribute] = value

    def get(self, attribute) :
        if attribute in self._dict.keys() :
            return self._dict[attribute]
        return self._parse(attribute)

    def load(self) :
        try :
            with open(self._filename(), 'r') as f:
                asj = f.read()
                self._dict = json.loads(asj)
        except Exception as E:
            self._dict = {}
            pass

    def dump(self) :
        try :
            with open(self._filename(), 'w') as f:
                f.write(json.dumps(self._dict,indent=4))
        except :
            pass

    def _parse(self, attribute : str) :
        if self._command is None :
            from sh import nix
            self._command = nix.eval.bake(f'-v --json --extra-experimental-features nix-command --extra-experimental-features flakes -L')
        eva = f'{self.flake}#nixosConfigurations.{self.hostname}.config.{attribute}'
        p = self._command(eva, _bg=True)
        i = 0
        while p.is_alive() :
            print('\r' f"Evaluating : {eva} {[x*'.' for x in range(1,4)][(i % 3)-1]}")
            sleep(0.1)
        json.loads()
        try :
            nix_dict = json.loads(nix_output)
            # cache result 
            self._dict[attribute] = nix_dict
            return nix_dict
        except Exception as E:
            print(f'Error : `{eva}` FAILED')
            exit(2)

    def _filename(self):
        return f'.config.{self.hostname}.json'