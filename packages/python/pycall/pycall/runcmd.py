#!/usr/bin/env python
# module to call shell commands neatly

# import local modules
from .output import Output
from .runner import Runner

# The main function of this module
def runcmd(command : str, **runner_args) -> Output :
    """
        run a shell command, does not print it's output
        but collects it in a dictionnary. 
        also logs what is happening
    """
    rn = Runner(command, **runner_args)
    rn.run()
    return rn.output

async def asyncruncmd(command : str, **runner_args) -> Output :
    rn = Runner(command, **runner_args)
    await rn.asyncrun()
    return rn.output