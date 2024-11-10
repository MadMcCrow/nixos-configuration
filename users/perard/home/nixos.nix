# linux.nix
# linux user configuration
{ pkgs, ... }:
{
  # import modules
  imports = [
    ./applications # TODO : make a module with options :
    ./git.nix
    ./shell.nix
    ./ssh.nix
    ./nixpkgs.nix # we need this module to work
  ];
  # home setup
  config = {
    home = {
      username = "perard";
      homeDirectory = "/home/perard";
      stateVersion = "23.11";
      packages = with pkgs; [
        fzf
        jetbrains-mono
        python3
        speechd
        bitwarden
      ];
    };

    xdg.mimeApps.enable = true;

    # gpg key management (linux only)
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
