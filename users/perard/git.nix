# git.nix
#   git and github settings
# TODO : switch to email through accounts.email
# TODO : share  with other users
{ pkgs, gitEmail, gitUser }: {

  packages = with pkgs; [ git gh ];

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
