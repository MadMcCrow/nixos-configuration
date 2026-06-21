#!/usr/bin/env python3
"""
Singleton MetaClass for Builder and Validator
"""


class SingletonMeta(type):
    __instances = {}

    def __call__(cls, *args, **kwargs):
        """
        Possible changes to the value of the `__init__` argument do not affect
        the returned instance.
        """
        if cls not in cls.__instances:
            instance = super().__call__(*args, **kwargs)
            cls.__instances[cls] = instance
        return cls.__instances[cls]
