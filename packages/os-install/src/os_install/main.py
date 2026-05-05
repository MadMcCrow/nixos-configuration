from os_install.cli import CliParser


def main() -> None:
    parser = CliParser()
    args = parser.parse_args()
