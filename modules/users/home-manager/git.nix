# home-manager/git.nix
#   git and github settings
{ pkgs, gitEmail, gitUser, useGit ? true }: {
  packages = if useGit then [ git gh ] else [ ];
  programs = {
    git = {
      enable = true;
      userName = gitUser;
      userEmail = gitEmail;
      lfs.enable = true;
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
