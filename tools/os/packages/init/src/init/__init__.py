from argparse import Namespace

from init.init_config import init_config


async def init_config_args(args: Namespace):
    """wrap init config in an sync call and extract the arguments from kvargs"""
    await init_config(dir=args.config, edit=args.edit, quiet=args.quiet)
