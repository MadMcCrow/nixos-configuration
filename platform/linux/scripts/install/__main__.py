#!/usr/bin/python
#
# script to install nixos on a machine 
#
# python script to replace the old bash install script
# we still run bash commands in the end, but the processing 
# of inputs is done in python for simplicity
# 

import filesystems

WELCOME='''Welcome to my nixOS installer.
this installer assume you already formatted your drives if you haven't done it yet, use applications like GPARTED to create the partitions.

No need to format to a specific filesystem, we'll do it for you.
run this script with `--show-partitions` to see what disks you needs
'''

if __name__ == "__main__" :
    # say hello:
    print(WELCOME)
    # building filesystems :
    filesystems.show_filesystems(hostname="terminus")
    

