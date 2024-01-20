#!/usr/bin/env python
#
#   files.py : functions to handle files
#
import os
from pwd import getpwnam, getpwuid
from grp import getgrnam, getgrgid
from colors import error

def fixPath(path) :
    abspath = os.path.abspath(path)
    relpath = f"./{os.path.relpath(path)}"
    return relpath if len(relpath) < len(abspath) else abspath

def removeFile(path) :
    try :
        os.remove(fixPath(path))
    except FileNotFoundError :
        pass

def fileExists(path):
    try:
        path = fixPath(path)
        return os.path.exists(path) and os.path.isfile(path)
    except:
        return False

def getFileUserGroup(path) :
    stats = os.stat(fixPath(path))
    return (getpwuid(prev_stats.st_uid).pw_name, getgrgid(prev_stats.st_gid).gr_name)

def splitUserGroup(owner: str) -> {str, str}:
    """
        from a "User[:Group]" string to a "User" "Group"
        if no group is provided, we default to the user's group
    """
    if owner == None :
        return False
    try :
        user,group = owner.split(':')
    except ValueError :
        user = owner
        group = getgrgid(getpwnam(owner).pw_gid).gr_name
    return user, group

def setOwnership(path: str, owner: str) -> bool:
    """
        Set owner ship of the path to the wanted user and group
        if no group is provided, we default to the user's group
    """
    path = fixPath(path)
    user, group = splitUserGroup(owner)
    uid, gid = getpwnam(user).pw_uid, getgrnam(group).gr_gid
    prev_owner = getFileUserGroup(path)
    os.chown(path,uid,gid)
    new_owner = getFileUserGroup(path)
    note(f"changed {path} from {':'.join(prev_owner)} to {':'.join(new_owner)}")
    return prev_stats != new_stats

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
        path = fixPath(path)
        with open(path, ('rb' if binary else 'r')) as f:
            return f.read()
    except Exception as E:
        print(f"failed to read {path}: {E}")
        raise E

def writeFile(path, content, binary = False) :
    try :
        path = fixPath(path)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, ('wb' if binary else 'w')) as f:
            return f.write(content)
    except Exception as E:
        error(f"failed to write to {path}")
        raise E
