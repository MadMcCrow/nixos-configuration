#!/usr/bin/env python
# Class to have async calls to programs

# default python modules
from typing import Callable
from datetime import datetime
import shutil, shlex
import asyncio
import locale

from packages.python.pycall.pycall.output import Output

# ours
from .callback import Callback
from .throbber import Throbber


class Command() :
    """
    Class for making shell calls asynchronously
    """

    args : list
    _out : Output
    _err : Output
    _callback : Callback
    _errcallback : Callback

    def __init__(self, cmd, out_func = None, err_func = None ) :
        # copy arguments :
        self.args = shlex.split(cmd)
        self._callback = Callback(out_func)
        self._errcallback = Callback(err_func)
        # check it make sens :
        if shutil.which(self.args[0]) is None:
            raise RuntimeError(f"{self.args[0]} : command not found")

    async def asyncrun(self) :
        # create the process task 
        ps = asyncio.create_task(self.__async_run_process())
        sp = asyncio.create_task(Throbber.update())
        await asyncio.wait([ps, sp], return_when=asyncio.FIRST_COMPLETED)
        return Output()
        

    async def __async_run_process(self) -> None :
        _pipe = asyncio.subprocess.PIPE
        self._err = Output()
        self._out = Output()
        ps = await asyncio.create_subprocess_exec(*self.args, stdout=_pipe, stderr=_pipe)
        print(f'PROCESS TASK = {ps}')
        async with asyncio.TaskGroup() as tg:
            tg.create_task(self.__read_stream(ps.stdout, [self._out , self._callback] ))
            tg.create_task(self.__read_stream(ps.stderr, [self._err , self._errcallback ]))
        rc = await ps.wait()
        print(f'Process {ps} returned {rc}')


    async def __read_stream(self, stream, cb_list):
        while True:
            line = await stream.readline()
            if line:
                for cb in cb_list :
                    cb(line.decode(locale.getencoding()))
            else:
                break