from .cli import Commands


def cli():
    cli = Commands("os", "NonOS utility program")
    cli.add_argument( "--verbose",
        "-v",
        action="store_true",
        help="add extra debug informations"
    )
    cli.add_command(
        "validate",
        [(
            description = "validate a config"
        )]
    )


def main() -> None:
    # for now, just run the CLI
