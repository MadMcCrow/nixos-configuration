#!/usr/bin/env python3
"""
validate a nonOS config or throw errors.
"""

import json

# our logging module
from log import error as ERROR  # pyright: ignore [reportAttributeAccessIssue]
from log import warning as WARNING  # pyright: ignore

from .config import Config


class Validator:
    def __init__(self, validation_path: str):
        """Initialize the Validator by loading validation rules from a TOML file.

        Args:
            validationPath (str): Path to the TOML file containing validation rules.
            The TOML file should contain:
            - valid_keys: List of all valid nonOS keys
            - mandatory_keys: List of keys that are mandatory
        """
        with open(validation_path, "r") as file:
            validation_data = json.load(file)
        self.valid_keys = validation_data.get("validKeys", [])
        self.mandatory_keys = validation_data.get("mandatoryKeys", [])

    def validate_config(
        self, config: Config | str, raise_on_error: bool = True
    ) -> bool:
        """Validate a nonOS config and raise exceptions for missing mandatory keys.

        Args:
            config (Config): The Config object to validate.
            raise_on_error (bool) : if true error raise exceptions, otherwise just logs.

        Raises:
            Exception: If mandatory keys are missing from the config.

        Returns:
            True if Config is valid for installation (warnings may exist)

        Logs:
            WARNING: If invalid keys are present in the config.
        """
        # convert to an actual config if was given as a string
        if isinstance(config, str):
            config = Config(config)

        # Check for missing mandatory keys
        missing_mandatory_keys = []
        for key in self.mandatory_keys:
            if config[key] is None:
                # Check if the key exists but has None value
                missing_mandatory_keys.append(key)

        # Check for invalid keys
        invalid_keys = []
        for path in config.get_key_paths():
            is_valid = False
            for key in self.valid_keys:
                if path.startswith(key):
                    is_valid = True
                    break
            if not is_valid:
                invalid_keys.append(path)

        # separated fromn the loop to give you all errors :
        sep = " "  # replace by "\n\t" for multi line log
        if missing_mandatory_keys:
            error_message = f"Missing mandatory configuration keys in {config.path}:{sep}{f',{sep}'.join(map(lambda x: f"'{x}'", missing_mandatory_keys))}"
            if raise_on_error:
                raise Exception(error_message)
            else:
                ERROR(error_message)
        if invalid_keys:
            WARNING(
                f"Invalid configuration keys found in {config.path}:{sep}{f',{sep}'.join(map(lambda x: f"'{x}'", invalid_keys))}"
            )
        # return if no blocking errors
        return len(missing_mandatory_keys) <= 0
