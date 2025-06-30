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

    def __call__(self, instr) :
        self[self.__time()] = instr

    def close(self) :
        # TODO execution duration measure
        pass