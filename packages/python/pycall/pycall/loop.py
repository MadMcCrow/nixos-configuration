#!/usr/bin/env python
# functions to get re-usable event loop :

import platform
import asyncio

def get_platform_loop() :
    if platform.system()=='Windows':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
        loop = asyncio.ProactorEventLoop() 
    else :
        loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    return self.loop

def get_default_loop() :
    try :
        loop = asyncio.get_event_loop()
        if not loop.is_closed() :
            return loop
    except : 
        pass
    finally :
        loop = get_platform_loop()
        return loop



    