import argparse


class CliParser(argparse.ArgumentParser):
    def __init__(self):
        super().__init__(
            prog="os-install",
            description=" install nonOS",
        )
        self.add_argument(
            "--verbose",
            "-v",
            action="store_true",
            help="Pass --show-trace to nixos-rebuild",
        )
        self.add_argument(
            "--show-config",
            action="store_true",
            help="Print the parsed config and exit without rebuilding",
        )
