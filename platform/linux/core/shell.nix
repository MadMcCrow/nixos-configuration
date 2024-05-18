# linux/shell.nix
#	default shell for linux
{ pkgs, config, lib, ... }:
let
  shell = pkgs.zsh;
  editor = pkgs.nano;
  ls = pkgs.eza;
in {

  config = {
    # ZSH :
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      histSize = 100;
      shellAliases = {
        ls = "${lib.getExe ls}";
        exa = "${lib.getExe ls}";
        nano = "${lib.getExe editor}";
        htop = "${lib.getExe pkgs.btop}";
      };
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };

    # make everyone use zsh
    users.defaultUserShell = shell;
    users.users.root.shell = shell;
    environment.shells = [ shell ];

    # packages that just make sens
    environment.defaultPackages = [ shell editor ls ] ++ (with pkgs; [
      nixfmt # format nix files
      #nixfmt-rfc-style
      wget
      curl
      zip # tar already present
      neofetch # because its cool ;)
      # hardware tools :
      lshw
      dmidecode
      pciutils
      usbutils
      psensor
      smartmontools
      lm_sensors
      policycoreutils # SELinux tool
      # git :
      git
      git-crypt
      pre-commit
      git-lfs
      # nix tools :
      cachix
      vulnix
    ]);

    # use nano as our editor :
    environment.variables.EDITOR = "${lib.getExe editor}";

    # disable the sudo warning for users (they might otherwise see it constantly):
    security.sudo.extraConfig = "Defaults        lecture = never";

  };
}
