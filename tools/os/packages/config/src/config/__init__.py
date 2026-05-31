#!/usr/bin/env python3
"""
expose selectively to the other modules
"""

# other modules might want to use Config objects
from .config import Config as Config

# you can/should use a single validator object for multiple configs
from .validator import Validator as Validator
