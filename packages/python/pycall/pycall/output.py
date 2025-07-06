#!/usr/bin/env python
# class to store the output from a command

from collections import UserDict
from datetime import datetime

class Output(UserDict) :

    @staticmethod
    def __time() :
        return datetime.now()

    def __init__(self) -> None:
        self.__start = self.__time()
        self['out'] = ""

    def stdout(self, instr) :
        self['out'] += instr

    def stderr(self, instr) :
        self['err'] += instr

    def __str__(self) -> str:
        return self['out']

    def close(self) :
        # TODO execution duration measure
        pass