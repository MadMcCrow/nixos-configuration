#!/usr/bin/env python3
"""
build a nonOS config or throw errors.
"""

# our logging module
from log import error as ERROR  # pyright: ignore [reportAttributeAccessIssue]
from log import warning as WARNING  # pyright: ignore


class Builder:
    """
    async object to run the nix build process and monitor it
    """

    def __init__(self):
        pass
