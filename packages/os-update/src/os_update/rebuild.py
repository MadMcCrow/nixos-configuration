"""Thin wrapper around nixos-rebuild."""

from __future__ import annotations

import shutil
import subprocess
import sys
from enum import StrEnum

from .config import MachineConfig


class Action(StrEnum):
    SWITCH    = "switch"
    BOOT      = "boot"
    TEST      = "test"
    DRY_BUILD = "dry-build"
    BUILD     = "build"


def nixos_rebuild(cfg: MachineConfig, action: Action, verbose: bool = False) -> None:
    """Run nixos-rebuild with the resolved flake reference."""

    if not shutil.which("nixos-rebuild"):
        print(
            "Error: 'nixos-rebuild' not found in PATH.\n"
            "This command must be run on a NixOS system.",
            file=sys.stderr,
        )
        sys.exit(1)

    cmd = [
        "nixos-rebuild", str(action),
        "--flake",  cfg.flake_ref,
        "--impure",
        "--option", "extra-experimental-features", "nix-command flakes",
    ]

    if verbose:
        cmd.append("--show-trace")

    print(f"  hostname  : {cfg.hostname}")
    print(f"  flake     : {cfg.flake_ref}")
    print(f"  system    : {cfg.system}")
    if cfg.revision:
        print(f"  pinned to : {cfg.revision}")
    print()

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        sys.exit(e.returncode)
