# need nix package "nixos-install-tools" and "nixos-install"

# ours
from cmd.awaitable import Awaitable

from tui.progress import Progress


class nixos_install(Awaitable):
    async def _exec(self, display: bool = True):
        """call nixos-install and generates the corresponding progress infos"""
        if display:
            async with Progress("installing nixos") as progress:
                with progress.info("generating config"):
                    pass
