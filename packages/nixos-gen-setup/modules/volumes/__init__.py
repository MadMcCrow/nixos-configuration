# volumes/__init__.py
#   Get mapper volumes ready :
from .luks import createluks, openluks
from .lvm import createlvm

def volumes() :
    createluks()
    openluks()
    createlvm()
