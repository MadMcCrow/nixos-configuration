#!/usr/bin/python
#
# config.py : parse a nixos config :

# python default imports
import json, subprocess, time, itertools, shlex, fcntl, os, shutil, atexit

_NL = '\n'

def _check_cmd(command) :
    program = shlex.split(command)[0]
    if shutil.which(program) is None :
        raise OSError(f'unknown command : \"{program}\"å')

def _non_block_read(output):
    fd = output.fileno()
    fl = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
    try:
        return output.read()
    except:
        return ""

# simple exec command
def _exec(command : str, display : str = "") -> (str, str) :
    _check_cmd(command)
    p = subprocess.Popen(shlex.split(command),
        bufsize = 1,
        stderr = subprocess.PIPE,
        stdout=subprocess.PIPE,
        universal_newlines=True)
    out = []
    err = []
    l = itertools.cycle([".  ",".. ","..."])
    while p.poll() is None :
        print(f"{display} {next(l)}", end="\r")
        out += [_non_block_read(p.stdout)]
        err += [_non_block_read(p.stderr)]
        time.sleep(0.001)
    print(f"{display} ... \x1b[0;32;6mDONE\x1b[0m")
    return (_NL.join(out)), (_NL.join(err))

class Config :

    def __init__(self,  hostname : str, flake : str = ".") :
        self.hostname = hostname
        self.flake = flake
        self._dict = dict()
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
        nix_config = f"{self.flake}#nixosConfigurations.{self.hostname}.config.{attribute}"
        nix_command = f"nix eval -v -L {nix_config} --json --extra-experimental-features nix-command --extra-experimental-features flakes"
        nix_output, nix_error = _exec(nix_command, f"\x1b[0;36;3mevaluating\x1b[0m \x1b[2;35;2m{nix_config}\x1b[0m")
        try :
            nix_dict = json.loads(nix_output)
            # cache result 
            self._dict[attribute] = nix_dict
            return nix_dict
        except Exception as E:
            print(f'Error : `{nix_command}` FAILED')
            print(f'Output : {nix_output.lstrip().rstrip()}')
            print(f'OutErr : {_NL.join(nix_error.splitlines()[-10:]).lstrip().rstrip()}')
            exit(2)

    def _filename(self):
        return f'.config.{self.hostname}.json'

