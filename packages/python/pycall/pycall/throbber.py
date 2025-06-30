#!/usr/bin/env python
# Class to display a simple throbber

import asyncio

class Throbber() :

    __characters = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
    __idx = 0
    __wait = 0.2

    @classmethod
    async def update(cls) :
        while True :
            cls.__idx = cls.__idx % len(cls.__characters)
            print(cls.__characters[cls.__idx], end='\r')
            await asyncio.sleep(cls.__wait)

