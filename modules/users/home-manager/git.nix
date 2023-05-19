# home-manager/git.nix
#   git and github settings
# TODO : switch to email through accounts.email
{ pkgs, gitEmail, gitUser, useGit ? true }: {
  packages = if useGit then [ git gh ] else [ ];
  programs = {
    git = {
      enable = true;
      userName = gitUser;
      userEmail = gitEmail;
      lfs.enable = true;
      config = {
        help.autocorrect = 10;
        color.ui = "auto";
      };
    };

    # github cli tool
    gh = {
      enable = true;
      enableGitCredentialHelper = true;
      settings.git_protocol = "https";
      extensions = [ gh-eco gh-cal gh-dash ];
    };
  };
}
