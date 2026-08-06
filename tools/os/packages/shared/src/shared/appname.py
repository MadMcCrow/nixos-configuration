from pathlib import Path
from sys import argv


def appname():
    """get a reasonable name for the currently running app"""
    exepath = Path(argv[0]).resolve()
    return str(exepath.name).removesuffix("-wrapped")


APPNAME = appname()
