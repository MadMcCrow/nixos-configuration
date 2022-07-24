# this is the configuration for users

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in {
  imports = [ (import "${home-manager}/nixos") ];

  # Users
  users.mutableUsers = false;

  # perard
  users.users.perard = {
    description = "Noé Perard-Gayot";
    isNormalUser = true;
    extraGroups = [ "wheel" "flatpak" "steam" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    home = "/home/perard";
    homeMode = "700";
    uid = 1000;
    shell = pkgs.zsh;
  };
  home-manager.users.perard = { lib, pkgs, ... }: {
    home = {
      packages = with pkgs; [
        home-manager
        zsh-powerlevel10k
        firefox
        chromium
        vlc
        dconf
        dconf2nix
        gnome.dconf-editor
        gnome.gnome-tweaks
        gnomeExtensions.pop-shell
        gnomeExtensions.caffeine
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.dock-from-dash
        gnomeExtensions.dash-from-panel
	gnomeExtensions.application-volume-mixer
	gnomeExtensions.mpris-indicator-button
	gnomeExtensions.dash-to-panel
	gnomeExtensions.advanced-alttab-window-switcher
	gnomeExtensions.top-bar-organizer
      ];
      stateVersion = "22.05";
    };
    programs = {
      zsh = {
        enable = true;
        initExtra = "[[ ! -f ~/.p10k/.p10k.zsh ]] || source ~/.p10k/.p10k.zsh";
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
          theme = "robbyrussell";
        };
	shellAliases = {
      		ls = "exa";
      	};
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource "/home/perard/.p10k/";
            file = ".p10k.zsh";
          }
        ];
      };
      git = {
        enable = true;
        userName = "MadMcCrow";
    	userEmail = "noe.perard@live.ru";
        lfs.enable = true;
        
      };
      gh = {
        enable = true;
        enableGitCredentialHelper = true;
        settings.git_protocol = "https";
      };

    };
  };
  
 fileSystems."/home/perard/Documents" = {
    device = "/home/documents";
    fsType = "none";
    options = [ "bind" ];
  };

  # guest
  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "guests" ];
    home = "/home/guest";
    homeMode = "764";
    uid = 1001;
  };
}
