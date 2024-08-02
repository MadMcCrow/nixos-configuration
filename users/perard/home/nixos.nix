# linux.nix
# linux user configuration
{ pkgs, ... }: {
  # import modules
  imports = [
    ./applications # TODO : make a module with options :
    ./git.nix
    ./shell.nix
    ./nixpkgs.nix # we need this module to work
  ];
  # home setup
  config = {
    home.username = "perard";
    home.homeDirectory = "/home/perard";
    home.stateVersion = "23.11";

    xdg.mimeApps.enable = true;

    # packages to install to profile
    home.packages = with pkgs; [ fzf jetbrains-mono python3 speechd bitwarden ];
    # gpg key management (linux only)
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
