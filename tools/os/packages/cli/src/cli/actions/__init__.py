#!/usr/bin/env python3
"""
actions setup for CLI
"""

__all__ = ["trigger_actions", "add_parser_actions", "_validate", "_build"]

# various actions
from . import build as _build
from . import validation as _validate
from .action import add_parser_actions, trigger_actions
