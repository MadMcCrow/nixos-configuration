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
        packages = [
          home-manager
          oh-my-zsh
          zsh-powerlevel10k
          gh # github
          lapce # code editor
          nemiver
          sysprof
          piper # mouse setting app
        ] ++ (with gnomeExtensions; [
          dash-to-dock
          pop-shell
          just-perfection
          blur-my-shell
          runcat
          timepp
          tiling-assistant
          forge
          arcmenu
          advanced-alttab-window-switcher
        ]);
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
                              POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true'';

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
              src = pkgs.fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-autosuggestions";
                rev = "v0.6.4";
                sha256 = "0h52p2waggzfshvy1wvhj4hf06fmzd44bv6j18k3l9rcx6aixzn6";
              };
            }
            {
              name = "fast-syntax-highlighting";
              src = pkgs.fetchFromGitHub {
                owner = "zdharma";
                repo = "fast-syntax-highlighting";
                rev = "v1.55";
                sha256 = "0h7f27gz586xxw7cc0wyiv3bx0x3qih2wwh05ad85bh2h834ar8d";
              };
            }
            {
              name = "powerlevel10k";
              src = pkgs.zsh-powerlevel10k;
              file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
          ];
        };

        # git settings
        git = {
          enable = true;
          userName = "MadMcCrow";
          userEmail = "noe.perard@live.ru";
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
