{ pkgs, ... }: {
  # Fonts
  fonts = {
    packages = with pkgs; [
      recursive
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
