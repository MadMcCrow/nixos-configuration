#!/usr/bin/env python3
"""
stdout and file log handlers
"""

# python imports
from logging import (
    FileHandler,
    Formatter,
)
from pathlib import Path

from .appname import name as appname


class LogfileHandler(FileHandler):
    """
    logHandler to write to a file at a correct directory
    """

    def __init__(self, path: str | None):
        if path is not None:
            pdir = Path(path)
            pdir.mkdir(parents=True, exist_ok=True)
            logfile = pdir / f"{appname}.log"
        else:
            logfile = Path(f"{Path.cwd()}/{appname}.log")
        # delete any existing log and return
        logfile.unlink(missing_ok=True)
        super().__init__(str(logfile), encoding="utf-8")
        self.formatter = Formatter(
            """%(name)s: %(levelname)s
            \t%(message)s
            \t\t(%(filename)s::%(funcName)s) [%(msecs)s ms]"""
        )
