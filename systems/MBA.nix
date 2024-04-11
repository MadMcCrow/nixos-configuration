# Nix configuration of MacBook Air
{ pkgs, lib, ... }: {

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
