#!/usr/bin/env python
# Class to display a simple throbber

import asyncio
import time
from concurrent import futures

__characters = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
__len = len(__characters)
__wait = 0.2


class Throbber() :
    """
    A simple throbber that runs in another thread
    """

    def __init__(self) -> None:
        self.__idx = 0
        self.__task = asyncio.create_task(self.__update())

    def cancel(self, fut) :
        print("THROBBER WAS CANCELLED!")
        self.__task.cancel()

    async def __update(self) :
        print("HELLO FROM THROBBER !")
        while True :
            self.__idx = (self.__idx + 1) % __len
            print(__characters[self.__idx], end='\r')
            await asyncio.sleep(__wait)

