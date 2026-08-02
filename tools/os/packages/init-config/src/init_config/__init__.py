from asyncio import run

from init_config.init_config import init_config


def init_config_args(**kvargs) :
    args = { k:v for k, v in kvargs.items() if k in ["dir", "hostname", "edit", "quiet"]}
    run(init_config(**args))