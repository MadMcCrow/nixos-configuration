#!/usr/bin/python
#
# a python dictionary like object but that points to a shared dict 

from typing import Any


def __subdict(d , k : str) -> dict :
        try: 
            return d[k]
        except KeyError:
            d[k] = None
            return d[k]


class UniqueDict() :
    """
        a dict that act as a singleton
    """

    __values : dict

    def key(self) :
        raise NotImplementedError("you need to implement key")

    @property
    def _values(self) -> dict :
        if self.key() not in self.__class__.__values :
            self.__class__.__values[self.key()] = {}
        return self.__class__.__values[self.key()]

    @_values.setter
    def _values(self, value) -> None :
        self.__class__.__values[self.key()].update(value)

    def __getitem__(self, key : str) -> Any:
        subkeys = key.split('.')
        sub = self._values
        for sk in subkeys[:-1] :
            sub = __subdict(sub, sk)
        try : 
            return sub[subkeys[-1]]
        except KeyError :
            sub[subkeys[-1]] = None
            return sub[subkeys[-1]]

    def __setitem__(self, key : str, item : Any) -> None:
        subkeys = key.split('.')
        sub = self._values
        for sk in subkeys[:-1] :
            sub = __subdict(sub, sk)
        sub[subkeys[-1]] = item

