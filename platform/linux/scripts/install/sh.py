# python default imports
import subprocess
import time
import itertools
import shlex
import fcntl
import os
import shutil

def check_cmd(command) :
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
def exec(command : str, display : str = "", Errors = False) -> str :
    check_cmd(command)
    p = subprocess.Popen(shlex.split(command),
        bufsize = 1,
        stderr = subprocess.PIPE if Errors else subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        universal_newlines=True)
    out = []
    err = []
    l = itertools.cycle([".  ",".. ","..."])
    while p.poll() is None :
        print(f"{display} {next(l)}", end="\r")
        out += [_non_block_read(p.stdout)]
        if Errors :
            err += [_non_block_read(p.stderr)]
        time.sleep(0.01)
    print(f"{display} ... DONE")
    if len(err) != 0 :
        print(f"WARN: {err}")
    return ("\n".join(out))