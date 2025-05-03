#!/usr/bin/python
#
# Evaluate a flake file

# standard python
from os import stat
from os.path import abspath, dirname, join, isfile, isdir, exists
import json
# pycall dependency
import pycall

_flakefilename = "flake.nix"

class Flake() :

    @staticmethod
    def getflakedir(path : str) -> str :
        if path.endswith("flake.nix") :
            path = dirname(path)
        if path.startswith("github:") or path.startswith("http") :
            return path
        if isfile(path) :
            return dirname(abspath(path))
        elif isdir(path): 
            return abspath(path)
        return ""

    @staticmethod
    def isflakepath(path : str) -> bool :
        """
        check if the path provided contains a flake
        """
        if path.startswith("github:") :
            return True
        if path.startswith("http") :
            return True
        if isdir(path) :
            return exists(join(path, "flake.nix"))
        if isfile(path) :
            return Flake.isflakepath(dirname(path)) 
        return False

    
    def __init__(self , flakepath = '.') :
        self.flakepath = Flake.getflakedir(flakepath)
        if self.flakepath is None :
            raise FileNotFoundError(f"cannot find {self.flakepath}")
        flakefile = join(self.flakepath, _flakefilename)
        evalflake = f"nix flake show {self.flakepath} --all-systems --json"
        result = pycall.runcmd(evalflake, stderr_level = 10)
        self._data = json.loads(str(result))

    def findOutput(self, value : str) -> str | None :
        """
            loop on outputs to find something
        """
        for output in self.listOutputs() :
            configs = list(self._data[output].keys())
            for key in configs :
                if str(key).casefold() == value.casefold():
                    return str(output)

    def getConfig(self, hostname) -> str | None :
        """
            get string representing the configuration for host
        """
        found = self.findOutput(hostname)
        if found is not None :
            return f"{self.flakepath}#{found}.{hostname}.config"

    def listOutputs(self, sub : str | None = None) -> list :
        if sub is None :
            return list(self._data.keys())
        else :
            return list(self._data[sub].keys())
        
    def __repr__(self) -> str:
        return f"nix flake at {self.flakepath}"

    @property
    def path(self) -> str | None :
        return self.flakepath


