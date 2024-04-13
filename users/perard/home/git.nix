# git.nix
# 	setup git with my user
{ lib, pkgs-latest, config, ... }: {

  home.packages = (with pkgs-latest; [
    git
    git-secrets
    git-credential-manager
    dotnet-runtime_7 # required by gcm
  ]);

  programs.git = {
    package = pkgs-latest.git;
    enable = true;
    userName = "MadMcCrow";
    userEmail = "noe.perard+git@gmail.com";
    lfs.enable = true;
    extraConfig = {
      help.autocorrect = 10;
      color.ui = "auto";
      core.whitespace = "trailing-space,space-before-tab";
      apply.whitespace = "fix";
      credential.helper =
        "${pkgs-latest.git-credential-manager}/lib/git-credential-manager/git-credential-manager";
    };
  };
  programs.gh = {
    package = pkgs-latest.gh;
    enable = true;
    settings.git_protocol = "https";
    extensions = with pkgs-latest; [ gh-eco gh-cal gh-dash ];
    gitCredentialHelper.enable = true;
  };
}
