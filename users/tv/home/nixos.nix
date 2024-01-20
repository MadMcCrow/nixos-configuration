# home.nix
# home manager configuration for user
{ config, pkgs, ... }:
with builtins; {
  home.username = "tv";
  home.homeDirectory = "/home/tv";
  home.stateVersion = "23.11";

  # add our dconf settings
  # imports = [ ];

  # packages to install to profile
  home.packages = (with pkgs; [ eza speechd fira-mono ]);

  # vscode is in another module (too many extensions)
  programs.vscode = (import ./vscode.nix { inherit pkgs; });

  # FIREFOX
  programs.firefox = {
    enable = true;
    package = pkgs.floorp;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
    gitCredentialHelper.enable = true;
  };
  programs.git-credential-oauth.enable = true;
}
