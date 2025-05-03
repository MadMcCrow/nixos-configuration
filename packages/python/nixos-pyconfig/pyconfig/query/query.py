#!/usr/bin/python
#
# configuration query : read and store config information

#python methods
import json
from os.path import basename
# our methods
from ..nix import Flake, Configuration
from .error import QueryError


class Query() :
    """ 
        A nice interface to retrieve configuration information
    """

    @staticmethod
    def select(options : list, question : str = "please choose :") :
        """
            simple menu question
        """
        choice = -1
        optionrange = range (0,len(options))
        while choice not in optionrange :
            print(question)
            for i in optionrange : 
                print(f"{i+1} - {options[i]}")
            choice = int(input()) - 1
        return options[choice]

    def __init__(self, *, filename : str, hostname : str, options : list | str) :
        self._results  = dict()
        if filename is None :
            filename = input("nix file to use :")
        if Flake.isflakepath(filename) :
            self._flake = Flake(filename)
            if hostname == None :
                output = Query.select(self._flake.listOutputs(), "select output :")
                hostname = Query.select(self._flake.listOutputs(output), "select host :")
            self._config = Configuration(flake = self._flake, host = hostname)
        else :
            self._config = Configuration(configfile=filename)
        if isinstance(options, str) :
           options = options.split(' ')
        elif isinstance(options, list) :
            options = options
        else :
            options = []
        # find out if it was already asked :
        self.readFromFile()
        # perform the query :
        self._results = self.queryOptions(options)

    def __del__(self):
        self.writeToFile()

    def queryOption(self, key) -> dict | str | list | None :
            """
            Search existing query result and ask nix if not found
            """
            keys = key.split('.')
            idx = 0
            d = self._results
            for k in keys[:-1] : # up to last but not last 
                try :
                     d = d[k]
                except KeyError :
                    d.update({k: dict()})
                    d = d[k]
            try : 
                if d[keys[-1]] is not None:
                    return d[keys[-1]]
            except KeyError:
                d[keys[-1]] = self._config.getAttr(str(key))
            return d[keys[-1]]

    def queryOptions(self, options) -> dict :
        """
            Query options, used cached answers if possible
        """
        result = dict()
        for opt in options :
            result.update({opt : self.queryOption(opt)})
        return result

    def _getFilename(self) -> str :
        return f".{basename(self._config.filepath)}-{self._config.host}.json"

    def readFromFile(self, filename : str = ""):
        try: 
            if filename == "" :
                filename = self._getFilename()
            txt = ""
            with open(filename, "r") as f:
                txt = f.read()
            obj = json.loads(txt)
            self._config = Configuration.fromstring(obj['config'])
            d = dict(obj['results'])
            for K,V in d.items() :
                ks = K.split('.')
                ks.reverse()
                t = V
                for k in ks :
                    t = {k : t}
                self._results.update(t)
        except FileNotFoundError :
            pass

    def writeToFile(self, filename : str = "") :
        if filename == "" :
            filename = self._getFilename()
        d = dict()
        d['config']  = self._config.tostring(format=0)
        d['results'] = self._results
        jsontxt = json.dumps(d, indent=4)
        with open(filename, "w") as f:
            f.write(jsontxt)

    def pretty(self) -> str :
        return json.dumps(self._results, indent=4)

    @property
    def hostname(self) :
        return self._config.host

    @property
    def configfile(self) :
        return self._config.filepath