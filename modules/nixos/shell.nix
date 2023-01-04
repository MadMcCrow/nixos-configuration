# nixos/shell.nix
# 	set default shell (zsh)
#	Todo : add power10k, move to a folder with the p10k default config
# Todo : move this out of nixos to enable it in MacOS
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.shell;
in {
  # interface
  options.nixos.shell.enable = mkEnableOption (mdDoc "zsh shell") // {
    default = true;
  };
  # config
  config = lib.mkIf (nos.enable && cfg.enable) {

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

  };
}
