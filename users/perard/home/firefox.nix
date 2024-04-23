# firefox.nix
# 	cooler firefox setup
{ pkgs, lib, ... }:
# maybe use an overlay instead !
let package = pkgs.librewolf.overrideAttrs (prev : {
  desktopItem = prev.desktopItem.overrideAttrs (prevItem:{
    keywords = ["firefox"];
  });
});
in {
  #

  programs.librewolf = {
    enable = true;
    inherit package;
    # see https://librewolf.net/docs/settings/
    settings = {
      "browser.sessionstore.resume_from_crash" = false;
      "privacy.clearOnShutdown.history" = false;
      "identity.fxaccounts.enabled" = true;
    };
  };
}
