#!/usr/bin/env python
# class to call when a runner parses a string 

class Callback() :

    def __init__(self, func = None) :
        self._func = func

    def __call__(self, instr : str) -> None :
        if self._func is not None :
            try :
                self._func(instr)
            except :
                pass