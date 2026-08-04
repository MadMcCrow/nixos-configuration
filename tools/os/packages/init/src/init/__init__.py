from argparse import Namespace
from asyncio import run
from init.init_config import init_config

def init_config_args(args : Namespace) :
    """ wrap init config in an sync call and extract the arguments from kvargs """
    run(init_config(
            dir = args.config,
            hostname = args.hostname,
            edit = args.edit,
            quiet = args.quiet
        ))