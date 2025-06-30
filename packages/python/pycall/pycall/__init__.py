#!/usr/bin/env python
# shortcut to avoid multiple imports
from .command import Command

import asyncio

def run(*args, **kwargs) : 
    r = Command(*args, **kwargs)
    asyncio.run(r.asyncrun())

async def async_run(*args, **kwargs) : 
    r = Command(*args, **kwargs)
    await r.asyncrun()