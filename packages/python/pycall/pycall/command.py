#!/usr/bin/env python
# Class to have async calls to programs

# default python modules
from typing import Callable
from datetime import datetime
import shutil, shlex
import asyncio
import locale



# ours
from .callback import Callback
from .throbber import Throbber
from .output   import Output


class Command() :
    """
    Class for making shell calls asynchronously
    """

    args : list
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
        th = Throbber()
        # create the process task 
        ps = asyncio.create_task(self.__async_run_process())
        ps.add_done_callback(th.cancel)
        return await ps
        

    async def __async_run_process(self) -> Output :
        _pipe = asyncio.subprocess.PIPE
        _out = Output()
        print("async process")
        ps = await asyncio.create_subprocess_exec(*self.args, stdout=_pipe, stderr=_pipe)
        print(f'PROCESS TASK = {ps}')
        async with asyncio.TaskGroup() as tg:
            tg.create_task(self.__read_stream(ps.stdout, [_out.stdout , self._callback] ))
            tg.create_task(self.__read_stream(ps.stderr, [_out.stderr , self._errcallback ]))
        rc = await ps.wait()
        print(f'Process {ps} returned {rc}')


    async def __read_stream(self, stream, cb_list):
        while True:
            print("_READ STREAM")
            line = await stream.readline()
            if line:
                for cb in cb_list :
                    cb(line.decode(locale.getencoding()))
            else:
                break