# darwin.nix
# MacOS user configuration
{ pkgs, ... }: {

  imports = [
    ./applications/vscode.nix
    ./shell.nix
    # ./git.nix # cannot get gcm (because dotnet mirror issue on MacOS)
  ];
  config = {
    home.username = "perard";
    home.homeDirectory = "/Users/perard";
    home.stateVersion = "23.11";

    # packages
    home.packages = with pkgs; [
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
}
