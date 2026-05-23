# packages/applications/default.nix
# Applications not available in nixOS that we provide
# You don't need to use nonOS to use them
{ mkDrvAttrs, ... }:
mkDrvAttrs [
      ./linux-arctis-manager.nix
    ]
