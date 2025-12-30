#! /usr/env python3
# flake parsing command

from pycall import Pycall
from slog import info


class Config(object):
    """
    A simple class to detect flakes and list outputs.
    """

    def __init__(self):
        pass

    async def outputs(self) -> list[str]:
        info(f"evaluating flake at : {self.path}")
        Pycall.call("nix", f"flake show {self.path}", [self._parseio])
        return []

    async def _parseio(stream: str, is_error: bool):
        # TODO !
        pass
