#!/usr/bin/env python3
"""
stdout log handlers with rich
"""

# python imports
from logging import Formatter
from sys import stdout

# rich is provided by uv
from rich.console import Console
from rich.highlighter import ReprHighlighter
from rich.logging import RichHandler
from rich.text import Text
from rich.theme import Theme


class ConfigHighlighter(ReprHighlighter):
    base_style = "log."
    highlights = [r"'(?P<quote>[\w.]+)'"]


class StdoutHandler(RichHandler):
    """
    stdout compatible handler
    """

    def __init__(self):
        theme = Theme(
            {
                "log.quote": "bold white",
                "log.base": "magenta",
            },
            inherit=True,
        )
        # formatstr
        format_text = Text("%(message)s", style="log.base")
        highlighter = ConfigHighlighter()
        # see https://rich.readthedocs.io/en/latest/reference/logging.html for options
        super().__init__(
            console=Console(file=stdout, theme=theme, highlighter=highlighter),
            highlighter=highlighter,
            markup=True,
            show_path=False,
            enable_link_path=True,
        )
        self.setFormatter(Formatter(format_text.markup))
