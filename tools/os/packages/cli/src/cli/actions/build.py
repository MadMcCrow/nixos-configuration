#!/usr/bin/env python3
"""
build configs with our tool
"""

from asyncio import TaskGroup, run
from typing import List

from config import (  # pyright: ignore [reportAttributeAccessIssue]
    Builder,
    Config,
    Validator,
)
from log import error, info

from .action import add_action


def build(config_paths: List[str]):
    """
    validate and build all configs at once !
    """
    validator = Validator()
    builder = Builder()

    async def async_build_task(cfg: Config):
        info(f"validating {cfg}")
        if await validator.validate(cfg):
            await builder.build(cfg)
        else:
            error(f"{cfg} is an invalid config, cannot build")

    async def run_tasks():
        async with TaskGroup() as tg:
            [tg.create_task(async_build_task(Config(p))) for p in config_paths]

    # run from the synchronous method
    run(run_tasks())


add_action(
    build,
    "build config(s)",
    parameter_descriptions={"config_paths": "list of configurations to build"},
)
