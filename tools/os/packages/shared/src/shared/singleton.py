# python imports
from typing import ClassVar, Any
from threading import Lock


class SingletonMeta(type):
    """ Singleton meta class for building singleton classes that works with multithreading """
    _lock: ClassVar[Lock] = Lock()
    _instances: ClassVar[dict] = {}

    def __call__(cls, *args: Any, **kwds: Any):
        with cls._lock:
            if cls not in cls._instances:
                instance = super().__call__(*args, **kwds)
                cls._instances[cls] = instance
        return cls._instances[cls]
