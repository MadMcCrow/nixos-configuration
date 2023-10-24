# linux/shell.nix
#	default shell for linux
{ pkgs, config, lib, ... }:
let
  # shortcut
  nxs = config.nixos;
  cfg = nxs.shell;
in
{
  options.nixos.shell = {
    package = lib.mkOption {
      description = "package to use as shell for everyone";
      type = lib.types.package;
      default = pkgs.zsh;
    };
    editor = lib.mkOption {
      description = "editor to use in shell";
      type = lib.types.package;
      default = pkgs.nano;
      # example = pkgs.vim;
    };
  };


  config = lib.mkIf nxs.enable {
    # ZSH :
    programs.zsh = {
      enable = cfg.package == pkgs.zsh;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      histSize = 100;
      shellAliases = {
        ls   = "eza";
        exa  = "eza";
        htop = "btop";
      };
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };
    # make everyone use zsh
    users.defaultUserShell = cfg.package;
    users.users.root.shell = cfg.package;
    environment.shells = [ cfg.package ];

    # packages that just make sens
    environment.defaultPackages =  [ cfg.package cfg.editor ] ++ (with pkgs;[
      nixfmt  # format nix files
      eza     # better ls with colors
      wget
      openssl
      git
      curl
      zip
      zenith
      btop
      neofetch  # because its cool ;)s
    ]);
    # use nano as our editor :
    environment.variables.EDITOR = "${cfg.editor}";

    # disable the sudo warning for users (they might otherwise see it constantly):
    security.sudo.extraConfig = "Defaults        lecture = never";
  };
}
