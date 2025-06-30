

from pyconfig import Query

class Volumes :


    def __init__(self, config) :

        for option in ["fileSystems", "boot.initrd.luks.devices", "services.lvm.enable"] :
            flake.