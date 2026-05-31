#!/usr/bin/env python3
"""
get the name of the binary that started us
"""

from pathlib import Path
from sys import argv

name = Path(argv[0]).name
# nix patch : remove 'wrapProgram' added characters
if name.startswith(".") and name.endswith("wrapped"):
    name = name.lstrip(".").rstrip("-wrapped")
