{ pkgs, ... }: {
  # Fonts
  fonts = {
    fonts = with pkgs; [
      recursive
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
