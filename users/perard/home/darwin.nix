# darwin.nix
# MacOS user configuration
{ pkgs, ... }:
{

  imports = [
    ./applications/vscode.nix
    ./shell
    ./ssh.nix
  ];
  config = {
    home = {
      username = "perard";
      homeDirectory = "/Users/perard";
      stateVersion = "24.05";

      # packages
      packages = with pkgs; [
        git
        git-secrets
        powerline-go
        zsh-autosuggestions
        zsh-syntax-highlighting
        jetbrains-mono
        python3
        nss_latest
      ];
    };
  };
}
