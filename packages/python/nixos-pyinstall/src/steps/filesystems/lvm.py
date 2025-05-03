#!/usr/bin/python
#
# PyInstaller LVM2 step
from .fs import FSStep

class LogicalVolumes(FSStep) :
    """
        Step to find and format logical volumes with lvm2
    """
    def __init__(self, parent) :
        # simply initialize super class :
        super().__init__(name="lvm2", parent=parent )

    def formatDisk(self):
        print(self.findVolumes())

    def findVolumes(self) :
        return self.getFileSystems()
