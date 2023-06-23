# firefox.nix
#   firefox web browser
{ pkgs }: {
  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
    };
  };
}
