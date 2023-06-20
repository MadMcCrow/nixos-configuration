# home-manager/git.nix
#   git and github settings
# TODO : switch to email through accounts.email
{ pkgs, gitEmail, gitUser, useGit ? true, ... }: {
  packages = if useGit then (with pkgs; [ git gh ]) else [ ];
  programs = {
    git = {
      enable = true;
      userName = gitUser;
      userEmail = gitEmail;
      lfs.enable = true;
      extraConfig = {
        help.autocorrect = 10;
        color.ui = "auto";
        core.whitespace = "trailing-space,space-before-tab";
        apply.whitespace = "fix";
      };
    };

    # github cli tool
    gh = {
      enable = true;
      enableGitCredentialHelper = true;
      settings.git_protocol = "https";
      extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
    };
  };
}
