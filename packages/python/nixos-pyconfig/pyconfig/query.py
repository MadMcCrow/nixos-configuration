#!/usr/bin/python
#
# configuration query : read and store config information

#python methods
import json
import asyncio
from os.path import basename
# our methods
from .configuration import Configuration
from pycall import get_default_loop

# optional dependency
try : 
    import tqdm
except ImportError:
    _tqdm_enable = False
else :
    _tqdm_enable = True




class QueryError(Exception) :
    """
        Error class for when a query fails !
        TODO : add option to pretty print what key failed and why !
    """
    pass



class Query() :
    """ 
        A nice interface to retrieve configuration information 
        using asyncio to perform faster :
    """

    def __init__(self, config : Configuration, keys : list, printProgress : bool = True) :
        self._config = config
        self._progress = printProgress and _tqdm_enable
        self._keys = keys
        # execute !
        get_default_loop().run_until_complete(self.runQuery())
        
    async def _nixQueryOption(self, key):
        result = await self._config.asyncGetValue(key)
        return result
 
    async def runQuery(self) :
        tasks = [self._nixQueryOption(k) for k in self._keys]
        if self._progress :
            bar =  tqdm(unit_scale=False, total=len(tasks))
            await tqdm_asyncio.gather(*tasks)
        else :
            while tasks : 
                finished,unfinished = asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
                for f in finished :
                    tasks.remove(f)
            print("please wait, while we gather config options")
            await asyncio.gather(tasks)

    @property
    def result(self) -> dict :
        ret = {}
        for k in self._keys :
            ret[k] = self._config[k]
            
