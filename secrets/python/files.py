#!/usr/bin/env python
#
#   files.py : functions to handle files
#
import os
from pwd import getpwnam
from grp import getgrnam

def removeFile(path) :
    try :
        os.remove(path)
    except FileNotFoundError :
        pass

def fileExists(path):
    try:
        return os.path.exists(path) and os.path.isfile(path)
    except:
        return False

def setOwnership(path: str, owner: str, group :str = None) -> bool:
    """
        Set owner ship of the path to the wanted user and group
        if no group is provided, we default to the user's group
    """
    if owner == None :
        return False
    uid = getpwnam(owner).pw_uid
    if group != None :
        gid = getgrnam(group).gr_gid
    else :
        gid = getpwnam(owner).pw_gid
    stats = os.stat(path)
    os.chown(path,uid,gid)
    return (stats.st_uid != uid or stats.st_gid != gid)

def setPermission(path : str, permission : str ) :
    """
        basically `chmod` with extra steps
    """
    try :
        os.chmod(path, int(permission, 8))
    except:
        return False
    else:
        return True

def readFile(path, binary = False) :
    try :
        with open(path, ('rb' if binary else 'r')) as f:
            return f.read()
    except Exception as E:
        print(f"failed to read {path}: {E}")
        return None


def writeFile(path, content, binary = False) :
    try :
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, ('wb' if binary else 'w')) as f:
            return f.write(content)
    except Exception as E:
        print(f"failed to write to {path}: {E}")
        return None
