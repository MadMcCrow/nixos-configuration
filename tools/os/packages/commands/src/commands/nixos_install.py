# need nix package "nixos-install-tools" and "nixos-install"

# ours
from commands.awaitable import Awaitable
from commands.progress import Progress


class nixos_install(Awaitable):
    async def _exec(self, display: bool = True):
        """ """
        if display:
            async with Progress("installing nixos") as progress:
                with progress.info("generating config"):
                    pass
