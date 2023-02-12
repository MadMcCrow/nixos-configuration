# perard.nix
# 	my user available on all my hosts
{ config, pkgs, lib, home-manager, ... }:
with builtins;
with lib;
let cfg = config.users.perard;
in {

  # interface
  options.users.perard = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "enable perard (me) user";
    };
    useDconf = lib.mkOption {
      type = types.bool;
      default = false;
      description = "use nix dconf settings";
    };
  };

  imports = [ home-manager.nixosModule home-manager.nixosModules.home-manager ];

  # conditional config
  config = lib.mkIf cfg.enable {
    # perard
    users.users.perard = {
      description = "Noé Perard-Gayot";

      isNormalUser = true;
      # I am admin, I can install flatpak apps and I'm a gamer :)
      extraGroups = [ "wheel" "flatpak" "steam" ];

      initialHashedPassword =
        "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";

      # home folder
      home = "/home/perard";
      homeMode = "700";
      uid = 1000;
      shell = pkgs.zsh;
    };

    # home manager configuration :
    home-manager.users.perard = { lib, pkgs, ... }: {
      home = with pkgs; {
        packages = [ home-manager oh-my-zsh zsh-powerlevel10k ];

        # just like for the base nixos configuration, do not touch
        stateVersion = "22.05";
      };

      # home manager programs settings 
      programs = {

        # zsh is a modern shell
        zsh = {
          enable = true;

          # source PowerLevel10k into my zsh config for a cool theme
          #	TODO : make this configuration from the flake
          initExtra = ''
            [[ ! -f ~/.p10k/.p10k.zsh ]] || source ~/.p10k/.p10k.zsh
                              POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          '';

          #enable profiling
          #initExtraFirst = "zmodload zsh/zprof";
          # initExtra = "zprof"

          # Oh-my-zsh is a tool improving shell usage
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "robbyrussell";
          };

          # replace ls by it's far superior alternative "exa"
          shellAliases = { ls = "exa"; };

          # zsh plugins
          plugins = [
            {
              name = "zsh-autosuggestions";
              src = pkgs.zsh-autosuggestions;
            }
            {
              name = "fast-syntax-highlighting";
              src = pkgs.zsh-fast-syntax-highlighting;
            }
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
          ];
          # smaller history
          history = {
            size = 100;
            ignoreDups = true;
            ignoreSpace = true;
            extended = false;
            share = true;
          };

        };

        # git settings
        git = {
          enable = true;
          userName = "MadMcCrow";
          userEmail = "noe.perard@live.ru"; #todo : switch to google email
          lfs.enable = true;
          # does not work with gh
          # extraConfig = "{help.autocorrect = 10;}";
        };

        # github cli tool
        gh = {
          enable = true;
          enableGitCredentialHelper = true;
          settings.git_protocol = "https";
        };
      };
    };
  };
}
