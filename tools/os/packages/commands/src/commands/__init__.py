#! /usr/bin/env python3

# selective imports
from commands.npins import npins
from commands.nixos_generate_config import nixos_generate_config
from commands.nixos_install import nixos_install
# make sure to expose
__all__ = ["nixos_generate_config", "npins"]