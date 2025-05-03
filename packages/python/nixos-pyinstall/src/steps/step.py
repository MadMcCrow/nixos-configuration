#!/usr/bin/python
#
# PyInstaller step
import asyncio


class Step() :
    """
    represent a step in the installation process
    """
    def __init__(   self,
                    name,
                    parent = None,
                    *,
                    progress_callable = None,
                    step_callable = None,
                    use_throbber :bool = False ) :
        self.parent = parent
        self.name = name
        self._task = None
        self._func_progress = progress_callable
        self._func_exec = step_callable
        self._use_throbber = use_throbber

    def run(self) :
        """
        call on asyncio
        """
        self._atask = asyncio.run(self._createTasks())

    async def _displayProgress(self) :
        try : 
            if self._func_progress is not None :
                self._func_progress()
            elif self._use_throbber :
                await self._throbber()
        except asyncio.CancelledError :
            pass # maybe raise ?

    async def _command(self) :
        if self._func_exec is None :
            raise RuntimeError("Nothing to be done !")
        else :
            self._func_exec()

    async def _createTasks(self) :
        """
        execute step
        """
        self._progress = asyncio.create_task(self._displayProgress())
        #self._maintask = asyncio.create_task(self._command())
        await asyncio.wait([self._progress], return_when = asyncio.FIRST_COMPLETED)


    async def _throbber(self) :
        try : 
            if self._func_progress is not None :
                self._func_progress()
            else : 
                m = 5
                c = ['.' * x for x in range(0,m)]
                i = 0
                while True :
                    i = i % m
                    print(f'STEP:{self.name}{c[i]}' , end='\r', flush=True)
                    i += 1
                    await asyncio.sleep(0.1) # avoid looping too fast
        except asyncio.CancelledError:
            print('', end='\r', flush=True)
            raise

    @property
    def outermost(self) :
        s = self
        while s.parent is not None :
            s = s.parent
        return s

