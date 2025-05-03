#!/usr/bin/python
#
# Evaluate a nixos-configuration, whether from file or from flake output

import json
from .flake import Flake
from pycall import runcmd

class Configuration() :

    def __init__(self,*, 
        configfile : str   | None = None,
        flake :      Flake | None = None,
        host :       str   | None = None ) :
        """
            this constructor works with both flake and non flake setup
        """
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

    def getAttr(self, option : str) -> str | dict | list :
        cmd = f"nix eval -v -L '{self._evalkey}.{option}' --json --extra-experimental-features {self._features}"
        result = runcmd(cmd, stderr_level = 10 ) # DEBUG = 10
        asstr = str(result)
        try :
            jsonobject = json.loads(asstr)
        except : 
            print(f"unexpected result for `{cmd}`\n got : \n {asstr}")
            return asstr
        try :
            return dict(jsonobject)
        except (TypeError, ValueError):
            try : 
                return list(jsonobject)
            except (TypeError, ValueError):
                return str(jsonobject)

    @classmethod
    def fromstring(cls, txt : str) :
        dictionary = dict(json.loads(txt))
        temp = dict()
        for x in ['flake', 'host', 'config'] :
            try :
                temp[x] = dictionary[x]
            except :
                temp[x] = None
                pass
        flake = None if temp['flake'] is None else Flake(temp['flake'])
        return cls(configfile=temp['config'], flake=flake, host = temp['host'])

    def tostring(self, format = 4 ) -> str :
        """
        turn the configuration into a saveable string
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
        return json.dumps(dictionary, indent=format)

    def __repr__(self) -> str:
        return f"{{config at : {self._evalkey}}} : {self.tostring()}"

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