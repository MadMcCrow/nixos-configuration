
#!/usr/bin/python
#
# PyInstaller LVM2 step

from ..step import Step

class FSStep(Step) :
    """
        Base Step class to handle filesystems
    """
    def __init__(self, parent, name) :
        # simply initialize super class :
        super().__init__(
            name=name,
            parent=parent,
            step_callable=self.formatDisk )

    def formatDisk(self) :
        raise NotImplementedError()
        pass

    def getFileSystems(self) :
        #filename : str, hostname : str, options : list | str
        outer = self.outermost
        query = outer.context.query
        return query.queryOptions("fileSystems")
