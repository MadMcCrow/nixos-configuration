#!/usr/bin/env python3
"""
stdout and file log handlers
"""

# import our initialization method
from inspect import getmodulename, stack

# import default logging methods
from logging import (
    DEBUG,
    INFO,
    basicConfig,
    getLogger,
)

from .appname import name as appname
from .file import LogfileHandler
from .stdout import StdoutHandler

__all__ = ["initialize", "info", "debug", "warning", "error"]

if "__initialized" not in dir():
    __initialized = False


def initialize(logpath: str | None = None):
    """
    Initialize slog system
    """
    global __initialized
    # reset default logger :
    getLogger().handlers = []
    getLogger().setLevel(0)
    # set stderr log :
    chandler = StdoutHandler()
    chandler.setLevel(INFO)
    # log to file :
    fhandler = LogfileHandler(logpath)
    fhandler.setLevel(DEBUG)
    # set log config :
    basicConfig(handlers=[fhandler, chandler], force=True)
    slogger = getLogger(appname)
    slogger.debug("initialized log")
    __initialized = True


def caller_id() -> tuple[str, str]:
    """Returns an informative prefix for log output messages"""
    s = stack()
    module_name = str(getmodulename(s[2][1]))
    func_name = s[2][3]
    return module_name, func_name


def error(msg: str):
    """log error with automatically the correct log category"""
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.error(f"{msg.strip()}")


def info(msg: str):
    """log information message with automatically the correct log category"""
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.info(f"{msg.strip()}")


def debug(msg: str):
    """log debug message with automatically the correct log category"""
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.debug(f"{msg.strip()}")


def warning(msg: str):
    """log warning with automatically the correct log category"""
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.warning(f"{msg.strip()}")
