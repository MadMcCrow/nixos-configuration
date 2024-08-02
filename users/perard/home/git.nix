# git.nix
# 	setup git with my user
{ pkgs, ... }: {

  home.packages = with pkgs; [
    git
    git-secrets
    git-credential-manager
    #dotnet-runtime_7 # required by gcm
    dotnet-sdk
  ];

  programs.git = {
    package = pkgs.git;
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
        "${pkgs.git-credential-manager}/lib/git-credential-manager/git-credential-manager";
    };
  };
  programs.gh = {
    package = pkgs.gh;
    enable = true;
    settings.git_protocol = "https";
    extensions = with pkgs; [ gh-eco gh-cal gh-dash ];

    gitCredentialHelper.enable = true;
  };
}
