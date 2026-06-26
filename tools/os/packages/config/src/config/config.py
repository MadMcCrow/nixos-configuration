#!/usr/bin/env python3
"""
nonOS TOML config file interactable object
"""

import json
import logging
from pathlib import Path
from typing import Any, List

import toml as TOML  # pyright: ignore; provided by uv


class Config:
    """A class to interact with a TOML config file."""

    def __init__(self, path: str):
        """Initialize the Config object by loading the TOML file from the given path.

        Args:
            path (str): Path to the TOML file to load.
        """
        self.__config_data: dict = {}
        self.path = Path(path)
        try:
            with open(path, "r") as file:
                self.__config_data = TOML.load(file)
        except FileNotFoundError:
            logging.error(f"Invalid configuration path: {self.path}")
            raise
        self.name = self.__config_data.get("hostname", str(self.path.stem))

    def __getattr__(self, key: str) -> Any:
        """Get the value associated with the given key as an attribute.

        Args:
            key (str): The key to look up in the config.

        Returns:
            The value associated with the key, or None if the key does not exist.
        """
        keys = key.split(".")
        value = self.__config_data

        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return None

        return value

    def __getitem__(self, key: str) -> Any:
        """get the value from config, with the '[]' operator

        Args:
            key (str): The key to look up in the config.

        Returns:
            The value associated with the key, or None if the key does not exist.
        """
        return getattr(self, key)

    def get_key_paths(self) -> List[str]:
        """get the paths that are set in this config"""
        return _get_leaf_paths(self.__config_data)

    def __str__(self) -> str:
        """get a simple string to identify this config"""
        return f"<host {self.name}@{self.path}>"

    def as_json(self) -> str:
        json_dict = json.dumps(self.__config_data)
        return f"<{self.__str__()}> :\n{json_dict}"


def _get_leaf_paths(d, path=None):
    """helper function : recursive method to help get the lead keys in a config."""
    if path is None:
        path = []
    leaf_paths = []
    for key, value in d.items():
        current_path = path + [key]
        if isinstance(value, dict):
            leaf_paths.extend(_get_leaf_paths(value, current_path))
        else:
            leaf_paths.append(".".join(current_path))
    return leaf_paths
