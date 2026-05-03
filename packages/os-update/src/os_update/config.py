"""Parsing and validation of /etc/nixos/config.toml."""

from __future__ import annotations

import tomllib
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_CONFIG_PATH = Path("/etc/nixos/config.toml")


@dataclass
class MachineConfig:
    flake:    str
    hostname: str
    system:   str
    timezone: str
    channel:  str           = "nixos-unstable"
    revision: str | None    = None
    # Everything else is passed through as-is to mkSystem
    extra:    dict           = field(default_factory=dict)

    # ------------------------------------------------------------------ #
    @classmethod
    def load(cls, path: Path = DEFAULT_CONFIG_PATH) -> "MachineConfig":
        if not path.exists():
            raise FileNotFoundError(
                f"Config file not found: {path}\n"
                "Create a config.toml in /etc/nixos/ to get started."
            )

        with path.open("rb") as f:
            raw = tomllib.load(f)

        _require(raw, "flake",    path)
        _require(raw, "hostname", path)
        _require(raw, "system",   path)
        _require(raw, "timezone", path)

        known = {"flake", "hostname", "system", "timezone", "channel", "revision"}

        return cls(
            flake    = raw["flake"],
            hostname = raw["hostname"],
            system   = raw["system"],
            timezone = raw["timezone"],
            channel  = raw.get("channel", "nixos-unstable"),
            revision = raw.get("revision"),
            extra    = {k: v for k, v in raw.items() if k not in known},
        )

    # ------------------------------------------------------------------ #
    @property
    def flake_ref(self) -> str:
        """Resolve the full flake reference, honoring optional revision pin."""
        base = self.flake.rstrip("/")
        if self.revision:
            # github:org/repo/rev  or  path/to/flake?rev=abc
            if base.startswith("github:") or base.startswith("gitlab:"):
                base = f"{base}/{self.revision}"
            else:
                base = f"{base}?rev={self.revision}"
        return f"{base}#default"


def _require(raw: dict, key: str, path: Path) -> None:
    if key not in raw:
        raise ValueError(f"Missing required field '{key}' in {path}")
