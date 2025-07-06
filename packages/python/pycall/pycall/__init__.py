#!/usr/bin/env python
# shortcut to avoid multiple imports
# python
import asyncio

# ours
from .command import Command
from .output import Output


def run(*args, **kwargs) -> Output : 
    r = Command(*args, **kwargs)
    return asyncio.run(r.asyncrun())

async def async_run(*args, **kwargs) -> Output: 
    r = Command(*args, **kwargs)
    return await r.asyncrun()