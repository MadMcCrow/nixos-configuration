#!/usr/bin/env python3
"""
nonOS TOML config file interactable object
"""

import toml


class Config:
    """A class to interact with a TOML config file."""

    def __init__(self, path: str):
        """Initialize the Config object by loading the TOML file from the given path.

        Args:
            path (str): Path to the TOML file to load.
        """
        with open(path, "r") as file:
            self.config_data = toml.load(file)

    def __getattr__(self, key: str):
        """Get the value associated with the given key as an attribute.

        Args:
            key (str): The key to look up in the config.

        Returns:
            The value associated with the key, or None if the key does not exist.
        """
        keys = key.split(".")
        value = self.config_data

        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return None

        return value
