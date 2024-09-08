# fonts.nix
# 	cool fonts I need on my systems
{
  config,
  pkgs,
  lib,
  ...
}:
let
  nerdFonts = with pkgs; [
    nerdfonts
    terminus-nerdfont
    powerline-fonts
    fira-code-nerdfont
  ];
  displayFonts = with pkgs; [
    noto-fonts
    open-sans
    roboto
    ubuntu_font_family
  ];
  monoFonts = with pkgs; [ jetbrains-mono ];
in
{
  config = {
    environment.defaultPackages = nerdFonts ++ displayFonts ++ monoFonts;
    fonts.fontDir.enable = true;
    console.packages = nerdFonts ++ monoFonts;
    fonts = {
      packages = nerdFonts ++ displayFonts ++ monoFonts;
      fontconfig = {
        defaultFonts.monospace = map lib.getName monoFonts;
        useEmbeddedBitmaps = true;
      };
    };
    # TODO :
    # console.font
  };
}
