#!/usr/bin/python
#
# configuration query : read and store config information

#python methods
import asyncio
# our methods
from .nix import Configuration
from pycall import get_default_loop

# optional dependency
try : 
    from tqdm import tqdm
    from tqdm.asyncio import tqdm_asyncio
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

    def __init__(self, config : Configuration, keys : list) :
        self._config = config
        self._keys = keys
        # execute !
        get_default_loop().run_until_complete(self.runQuery())
        
    async def _nixQueryOption(self, key):
        result = await self._config.asyncGetValue(key)
        return result
 
    async def runQuery(self) :
        tasks = [asyncio.create_task(self._nixQueryOption(k)) for k in self._keys]
        if _tqdm_enable :
            bar =  tqdm(unit_scale=False, total=len(tasks))
            await tqdm_asyncio.gather(*tasks)
        else :
            while tasks : 
                print("please wait, while we gather config options")
                finished,unfinished = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
                for f in finished :
                    tasks.remove(f)
            await asyncio.gather(*tasks)

    @property
    def result(self) -> dict :
        ret = {}
        for k in self._keys :
            ret[k] = self._config[k]
        return ret

            
