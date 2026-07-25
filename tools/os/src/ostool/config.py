from pathlib import Path
from typing import Dict

CONFIG_FILES = ["configuration.nixhardware-configuration.nixnpins"]


class Config:
    def __init__(self, dir: Path | str | None):
        """initialize the config directory"""
        if dir is None:
            dir = Path("./")
        self._root = Path(dir)

    def file(self, filename, check_exists=False) -> Path:
        """build a path to a file in the config"""
        file = self._root.joinpath(filename)
        if check_exists and not file.exists():
            raise FileNotFoundError(file)
        return file.resolve()

    def config_files(self, check_exists=False) -> Dict[str, Path]:
        """make a dict pointing to all the config files in the config"""
        return {x: self.file(x) for x in CONFIG_FILES}
