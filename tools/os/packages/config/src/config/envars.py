#!/usr/bin/env python3
"""
environment variables necessary for os-tool
"""

from os import environ, getenv
from typing import Dict, List

from log import error


class EnvironmentVariable:
    """
    class to improve reading from environment variables
    """

    # inner private properties
    __name: str
    __value: str

    def __init__(self, key: str):
        """Create or retrieve the environment variable"""
        # make sure the name is path compatible
        self.__name = key.capitalize().replace("-", "_")
        self.update_value()

    def ovewrite_value(self, new_value: str):
        """write to this environment variable and into the shared dictionnary"""
        self.__value = new_value
        _envars[self.key()] = self
        return
        environ[self.flag()] = self.__value

    def update_value(self):
        """update this to match previous definition"""
        if self.key() not in _envars.keys():
            self.ovewrite_value(getenv(self.flag()) or "")
        else:
            self = _envars[self.key()]
        _envars[self.key()] = self

    def __str__(self):
        """get the value when doing str(EnvironmentVariable())"""
        return self.get_value()

    def __repr__(self) -> str:
        return f"{self.flag()} : {self.get_value()}"

    def get_value(self) -> str:
        return str(self.__value)

    def flag(self) -> str:
        """
        return the ENVIRONMENT flag
        """
        return self.__name.upper().replace("-", "_")

    def key(self) -> str:
        """
        return a lower case version for argument parser and used internally
        """
        return self.__name.lower().replace("_", "-")

    @classmethod
    def get(cls, name: str) -> EnvironmentVariable:
        """ """
        name = name.lower().replace("_", "-")  # ensure name is a key
        try:
            return _envars[name]
        except KeyError:
            error(f"environment variable {name} is not defined")
            return cls(name)

    @staticmethod
    def list_variables() -> List[EnvironmentVariable]:
        """get all the defined names"""
        return list(_envars.values())


# keep track of all environment variables defined
_envars: Dict[str, EnvironmentVariable] = {}
