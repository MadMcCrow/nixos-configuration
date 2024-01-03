#!/usr/bin/env python
#
#   files.py : functions to handle files
#
import os
from pwd import getpwnam
from grp import getgrnam
from colors import error

def _fixPath(path) :
    path = os.path.abspath(path)
    return f"./{os.path.relpath(path)}"

def removeFile(path) :
    try :
        os.remove(_fixPath(path))
    except FileNotFoundError :
        pass

def fileExists(path):
    try:
        path = _fixPath(path)
        return os.path.exists(path) and os.path.isfile(path)
    except:
        return False

def setOwnership(path: str, owner: str, group :str = None) -> bool:
    """
        Set owner ship of the path to the wanted user and group
        if no group is provided, we default to the user's group
    """
    path = _fixPath(path)
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
        path = _fixPath(path)
        with open(path, ('rb' if binary else 'r')) as f:
            return f.read()
    except Exception as E:
        print(f"failed to read {path}: {E}")
        raise E


def writeFile(path, content, binary = False) :
    try :
        path = _fixPath(path)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, ('wb' if binary else 'w')) as f:
            return f.write(content)
    except Exception as E:
        error(f"failed to write to {path}")
        raise E
