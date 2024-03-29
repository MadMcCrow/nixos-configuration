# Nix configuration of MacBook Air
{ pkgs, lib, ... }: {

  platform = "aarch64-darwin";

  nix = {
    settings = { trusted-users = [ "@admin" ]; };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  programs = {
    zsh.enable = true;
    nix-index.enable = true;
  };

  # Auto upgrade nix package and the daemon service.
  services = { nix-daemon.enable = true; };

  # https://github.com/nix-community/home-manager/issues/423
  #environment.variables = {
  #  TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  #};

  # Fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      recursive
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  system = { keyboard.enableKeyMapping = true; };

}
