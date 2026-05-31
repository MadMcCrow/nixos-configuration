#!/usr/bin/env python3
"""
stdout log handlers with rich
"""

# python imports
from logging import Formatter
from sys import stdout

# rich is provided by uv
from rich.console import Console
from rich.highlighter import Highlighter, RegexHighlighter
from rich.logging import RichHandler
from rich.text import Text
from rich.theme import Theme

from .appname import name as appname


class ConfigHighlighter(RegexHighlighter):
    base_style = "config."
    highlights = [
        r"?P<quoted>'([^']*)'"
        r"(?P<configKey>([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\.[a-zA-Z0-9]+",
    ]


class StdoutHandler(RichHandler):
    """
    stdout compatible handler
    """

    def __init__(self):
        self.theme = Theme(
            {"message": "magenta", "name": "bold blue"},
            inherit=True,
        )
        self.formatter = Formatter(
            f"[name]{appname}-%(name)s[/]:[message]%(message)s[/]"
        )
        # see https://rich.readthedocs.io/en/latest/reference/logging.html for options
        super().__init__(
            console=Console(file=stdout, theme=self.theme),
            highlighter=ConfigHighlighter(),
            markup=True,
            show_path=False,
            enable_link_path=False,
        )
