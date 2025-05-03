


class Context() :
    """
        a class to reference the config we're installing more easily
    """

    def __init__(self) :
        raise NotImplementedError("Do not use Context directly")


    @property
    def configuration(self) :
        try :
            return self._config
        except: 
            return None
