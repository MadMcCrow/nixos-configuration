from os import R_OK, W_OK, access
from pathlib import Path

CONFIG_FILES = ["configuration.nix", "hardware-configuration.nix", "npins"]
CONFIG_DIRS = ["/etc/nonOS", "/etc/nixOS"]


class Config:
    def __init__(self, dir: Path | str | None):
        """
        initialize the config directory
        if no path is provided, search for the correct one
        """
        if dir is None:
            for d in map(Path, CONFIG_DIRS):
                try:
                    if (
                        d.exists()
                        and any(d.joinpath(x).exists() for x in CONFIG_FILES)
                        and access(d, R_OK | W_OK)
                    ):
                        dir = d
                        break
                except PermissionError:
                    pass
        self._root = Path(dir or "")

    def file(self, filename, check_exists=False) -> Path:
        """build a path to a file in the config"""
        file = self._root.joinpath(filename)
        if check_exists and not file.exists():
            raise FileNotFoundError(file)
        return file.resolve()

    def __getitem__(self, key: str) -> Path:
        assert key in CONFIG_FILES, f"can only get one of {CONFIG_FILES}"
        return self.file(key)

    def config_files(self, check_exists=False) -> dict[str, Path]:
        """make a dict pointing to all the config files in the config"""
        return {x: self.file(x) for x in CONFIG_FILES}

    def is_valid(self) :
        """ check whether the config has all its components """
        return all(self.file(x).exists() for x in CONFIG_FILES)
