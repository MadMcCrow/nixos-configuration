# Nix configuration of MacBook Air
{ pkgs, lib, ... }:
{

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trustedUsers = [
      "@admin"
    ];

    package = pkgs.nixUnstable;

    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  users.nix.configureBuildUsers = true;

  programs = {
    zsh.enable = true;
    nix-index.enable = true;
  };

  # Auto upgrade nix package and the daemon service.
  services = {
     nix-daemon.enable = true;
  };

  # https://github.com/nix-community/home-manager/issues/423
  #environment.variables = {
  #  TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  #};

  # Fonts
  fonts = {
  enableFontDir = true;
  fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
   ];
   };

  system = {
    keyboard.enableKeyMapping = true;
  };

  security = {
    pam.enableSudoTouchIdAuth = true;
  };
}