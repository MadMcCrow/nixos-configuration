#!/usr/bin/env python3
"""
validate a nonOS config or throw errors.
"""

import logging
from typing import Any, Dict, List

import toml

from .config import Config


class Validator:
    def __init__(self, validationPath: str):
        """Initialize the Validator by loading validation rules from a TOML file.

        Args:
            validationPath (str): Path to the TOML file containing validation rules.
            The TOML file should contain:
            - nonOS_keys: List of all valid nonOS keys
            - mandatory_keys: List of keys that are mandatory
        """
        with open(validationPath, "r") as file:
            validation_data = toml.load(file)

        self.nonOS_keys = validation_data.get("nonOS_keys", [])
        self.mandatory_keys = validation_data.get("mandatory_keys", [])

    def validate_config(self, config: Config) -> None:
        """Validate a nonOS config and raise exceptions for missing mandatory keys.

        Args:
            config (Config): The Config object to validate.

        Raises:
            Exception: If mandatory keys are missing from the config.

        Logs:
            WARNING: If invalid keys are present in the config.
        """
        # Check for missing mandatory keys
        missing_mandatory_keys = []
        for key in self.mandatory_keys:
            if not hasattr(config, key):
                missing_mandatory_keys.append(key)
            elif getattr(config, key) is None:
                # Check if the key exists but has None value
                missing_mandatory_keys.append(key)

        if missing_mandatory_keys:
            raise Exception(
                f"Missing mandatory configuration keys: {', '.join(missing_mandatory_keys)}"
            )

        # Check for invalid keys
        invalid_keys = []
        config_keys = self._get_all_config_keys(config.config_data)

        for key in config_keys:
            if key not in self.nonOS_keys:
                invalid_keys.append(key)

        if invalid_keys:
            logging.warning(
                f"Invalid configuration keys found: {', '.join(invalid_keys)}"
            )

    def _get_all_config_keys(self, data: Dict[str, Any], prefix: str = "") -> List[str]:
        """Recursively extract all keys from a nested dictionary structure.

        Args:
            data (Dict[str, Any]): The dictionary data to extract keys from.
            prefix (str): The prefix for nested keys.

        Returns:
            List[str]: List of all keys found in the data structure.
        """
        keys = []
        if isinstance(data, dict):
            for key, value in data.items():
                full_key = f"{prefix}{key}" if prefix else key
                keys.append(full_key)
                keys.extend(self._get_all_config_keys(value, f"{full_key}."))
        elif isinstance(data, list):
            for i, item in enumerate(data):
                keys.extend(self._get_all_config_keys(item, f"{prefix}{i}."))

        return keys
