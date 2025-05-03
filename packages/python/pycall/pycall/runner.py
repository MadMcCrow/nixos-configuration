#!/usr/bin/env python
# Class to have async calls to programs

# default python modules
from datetime import datetime
import shutil, shlex
import logging
import platform
import asyncio
import locale

# our python submodule
from .output import Output


class Runner() :
    """
    Class for managing async calls
    """

    def _getasyncloop(self) :
        try :
            if not self._loop.is_closed() :
                return self._loop
        except AttributeError :
            pass
        if platform.system()=='Windows':
            loop = asyncio.ProactorEventLoop()
            asyncio.set_event_loop(loop)
            asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
        else:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(asyncio.new_event_loop())
        self._loop = loop
        return self._loop

    def __init__(self, command, callback = None, use_log = True, stderr_level = logging.ERROR) :
        self.args = shlex.split(command)
        if shutil.which(self.args[0]) is None:
            raise RuntimeError(f"{self.args[0]} : command not found")
        self.out = Output()
        self.callback = callback
        self.log = logging.getLogger(self.args[0]) if use_log else None
        self.error_level = stderr_level
    
    def run(self) :
        start = datetime.now()
        self._loginfo(f"running : `{' '.join(self.args)}`")
        rc = self._getasyncloop().run_until_complete(self.asyncrun())
        elapsed = datetime.now() - start
        self._loginfo(f"execution took {elapsed}")
        return rc

    def _loginfo(self, txt) :
         if self.log :
            self.log.info(txt)

    def _logerr(self, txt) :
         if self.log :
            self.log.log(self.error_level ,txt)

    def _onReadstdout(self, line) :
        self._loginfo(line)
        self.out.addLine(line)
        if self.callback is not None :
            self.callback(line)
        
    def _onReadstderr(self, line) :
        self._logerr(line)
        self.out.addError(line)

    async def _read_stream(self, stream, cb):
        while True:
            line = await stream.readline()
            if line:
                cb(line.decode(locale.getencoding()))
            else:
                break
      
    async def asyncrun(self):
        p = await asyncio.create_subprocess_exec(*self.args,
                stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
        stdoutparser = asyncio.create_task(self._read_stream(p.stdout, self._onReadstdout))
        stderrparser = asyncio.create_task(self._read_stream(p.stderr, self._onReadstderr))
        await asyncio.wait([stdoutparser, stderrparser])
        return await p.wait()

    @property
    def output(self):
        return self.out