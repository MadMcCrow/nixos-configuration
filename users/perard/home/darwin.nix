# darwin.nix
# MacOS user configuration
{ config, pkgs, lib, pkgs-latest, ... }: {

  imports = [ ./vscode.nix ./shell.nix ./git.nix ];
  config = {
    home.username = "perard";
    home.homeDirectory = "/Users/perard";
    home.stateVersion = "23.11";

    # packages
    home.packages = with pkgs-latest; [
      git
      git-secrets
      git-credential-manager
      powerline-go
      eza
      zsh-autosuggestions
      zsh-syntax-highlighting
      jetbrains-mono
      python3
      nss_latest
    ];
  };
}
