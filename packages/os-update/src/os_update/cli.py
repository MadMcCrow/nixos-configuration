"""os-update — update a NonOS system from /etc/nixos/config.toml."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .config import DEFAULT_CONFIG_PATH, MachineConfig
from .rebuild import Action, nixos_rebuild


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="os-update",
        description="Update a NixOS system from a local TOML config file.",
    )

    parser.add_argument(
        "--config",
        "-c",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        metavar="PATH",
        help=f"Path to config TOML (default: {DEFAULT_CONFIG_PATH})",
    )
    parser.add_argument(
        "--action",
        "-a",
        type=Action,
        choices=list(Action),
        default=Action.SWITCH,
        help="nixos-rebuild action to run (default: switch)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_const",
        dest="action",
        const=Action.DRY_BUILD,
        help="Shorthand for --action dry-build",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Pass --show-trace to nixos-rebuild",
    )
    parser.add_argument(
        "--show-config",
        action="store_true",
        help="Print the parsed config and exit without rebuilding",
    )

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    try:
        cfg = MachineConfig.load(args.config)
    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if args.show_config:
        _print_config(cfg)
        return

    print(f">> os-update  [{args.action}]")
    nixos_rebuild(cfg, action=args.action, verbose=args.verbose)


def _print_config(cfg: MachineConfig) -> None:
    print("Parsed config:")
    print(f"  flake    = {cfg.flake}")
    print(f"  hostname = {cfg.hostname}")
    print(f"  system   = {cfg.system}")
    print(f"  timezone = {cfg.timezone}")
    print(f"  channel  = {cfg.channel}")
    if cfg.revision:
        print(f"  revision = {cfg.revision}")
    if cfg.extra:
        print("  extra    =")
        for k, v in cfg.extra.items():
            print(f"    {k} = {v!r}")
    print()
    print(f"  flake_ref → {cfg.flake_ref}")
