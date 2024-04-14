# linux.nix
# linux user configuration
{ config, pkgs, lib, pkgs-latest, ... }@args: {
  # import modules
  imports = [
    ./dconf.nix
    ./deezer.nix
    ./discord.nix
    ./firefox.nix
    ./games.nix
    ./git.nix
    ./media.nix
    ./shell.nix
    ./vscode.nix
    ./wallpaper.nix
  ];
  # home setup
  config = {
    home.username = "perard";
    home.homeDirectory = "/home/perard";
    home.stateVersion = "23.11";

    # packages to install to profile
    home.packages = with pkgs;
      [ blender ] ++ (with pkgs-latest; [
        jetbrains-mono
        python3
        speechd
        bitwarden
        openscad
        solvespace
      ]);
    # gpg key management (linux only)
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
