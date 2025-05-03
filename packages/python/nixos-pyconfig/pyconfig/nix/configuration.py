#!/usr/bin/python
#
# Evaluate a nixos-configuration, whether from file or from flake output

import json
from .flake import Flake
from pycall import async_run_cmd
from os.path import basename

class Configuration() :

    def __init__(self,*, 
        configfile : str   | None = None,
        flake :      Flake | None = None,
        host :       str   | None = None ) :
        """
            this constructor works with both flake and non flake setup
        """
        self._values = dict()
        initerror = ValueError("Configuration needs either a config file or a flake")
        # choose what subcontructor to use
        if configfile is not None :
            if flake is not None :
                raise initerror
            self._from_config(configfile)
        elif flake is not None :
            if configfile is not None :
                raise initerror
            if host is None :
                raise ValueError("Flakes must provide a hostname")
            self._from_flake(flake, host)
        # try to grab what we previously parsed !
        self.parseFromJson()

    def _from_config(self, configfile) :
        self._configfile = configfile
        self.evalkey = ""
        self._features = "\'nix-command\'"
        raise NotImplementedError("TODO : configuration from config file !")

    def _from_flake(self, flakeObject : Flake, hostname) :
        self._flake = flakeObject
        self._hostname = hostname
        self._evalkey = self._flake.getConfig(self._hostname)
        self._features = "\'nix-command flakes\'"

    async def _nix_eval_cmd(self, option : str) :
        """
            Warning :  this is slow
        """
        cmd = f"nix eval -v -L '{self._evalkey}.{option}' --json --extra-experimental-features {self._features}"
        result = await async_run_cmd(cmd, stderr_level = 10 ) # DEBUG = 10
        asstr = str(result)
        try :
            jsonobject = json.loads(asstr)
        except :
            #raise ValueError(f"unexpected result for `{cmd}` got : {asstr}")
            pass
        else: 
            self._values[option] = jsonobject

    async def asyncGetValue(self, option : str) :
        """
            retrieve the value for option, one way or another
        """
        try : 
            self._values[option]
        except KeyError :
            await self._nix_eval_cmd(option)
        finally:
            try :
                return self._values[option]
            except :
                return None
    
    def __repr__(self) -> str:
        """
        turn the configuration into a readable string
        """
        dictionary = dict()
        try : 
            dictionary['flake'] = self._flake.flakepath
        except:
            pass
        try :
            dictionary['config'] = self._configfile
        except :
            pass
        try :
            dictionary['host'] = self._hostname
        except :
            pass
        
        return f"{{config at : {self._evalkey}}} : {json.dumps(dictionary, indent=format)}"



    def __getitem__(self,key):
        try :
            return self._values[key]
        except KeyError :
            return None

    @property
    def host(self) -> str :
        return self._hostname

    @property
    def filepath(self) -> str :
        try :
           return self._flake.flakepath
        except :
            pass
        try : 
            return self._configfile
        except :
            return ""

    def parseFromJson(self) :
        try: 
            filename = self._getFilename()
            with open(filename, "r") as f:
                txt = f.read()
            d = dict(json.loads(txt))
            for K,V in d.items() :
                ks = K.split('.')
                ks.reverse()
                t = V
                for k in ks :
                    t = {k : t}
                self._values.update(t)
        except FileNotFoundError :
            pass


    def writeToJson(self) :
        filename = self._getFilename()
        jsontxt = json.dumps(self._values, indent=2)
        with open(filename, "w") as f:
            f.write(jsontxt)


    def _getFilename(self) -> str :
        return f".{basename(self.filepath)}-{self.host}.json"


