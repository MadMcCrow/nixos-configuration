# core/shell.nix
# 	set default shell (zsh)
#	Todo : add power10k, move to a folder with the p10k default config
{ pkgs, config, lib, ... }: {

  # Packages
  environment = {
    systemPackages = with pkgs; [ nixfmt zsh exa nano wget openssl ];
    pathsToLink = [ "/share/zsh" ];
  };

  # enable zsh for all
  programs.zsh = {
    enable = true;
    # settings
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    histSize = 100;

    # useful aliases
    shellAliases = { ls = "exa"; };

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # make users default to zsh
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # disable sudo "lecture"
  security.sudo.extraConfig = "Defaults        lecture = never";

}
