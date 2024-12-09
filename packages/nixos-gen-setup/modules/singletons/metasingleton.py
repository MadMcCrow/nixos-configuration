#
#   MetaSingleton 
#       A class to make singletons easy  
#
class MetaSingleton(type):
    """
    meta class way for defining Config as a singleton
    """
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            instance = super().__call__(*args, **kwargs)
            cls._instances[cls] = instance
        return cls._instances[cls]
