#!/usr/bin/env python3
"""
add the config validation action to our tool
"""

import asyncio
from typing import List

from config import Config, EnvironmentVariable, Validator
from log import info

from .action import add_action

CONFIG_KEYS = EnvironmentVariable("OS_CONFIG_KEYS")


def validate(config_paths: List[str]):
    validator = Validator()

    async def async_validate_task(cfg: Config):
        info(f"validating {cfg}")
        await validator.validate(cfg)

    async def run_tasks():
        async with asyncio.TaskGroup() as tg:
            [tg.create_task(async_validate_task(Config(p))) for p in config_paths]

    asyncio.run(run_tasks())


add_action(
    validate,
    "validate config(s)",
    parameter_descriptions={"config_paths": "list of configurations to validate"},
)
