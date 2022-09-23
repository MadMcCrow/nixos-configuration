# this is the configuration for users
{ inputs, lib, config, pkgs, ... }: {
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
    home = with pkgs; {
      packages = [
        home-manager
        oh-my-zsh
        zsh-powerlevel10k
        git
        gh
        firefox-wayland # default firefox has issues with wayland
        #chromium
        lapce # code editor
        vlc
      ] ++ (with gnomeExtensions; [
        caffeine
        appindicator
        dash-to-dock
        pop-shell
        #forge
        #arcmenu
        #advanced-alttab-window-switcher
        application-volume-mixer
        mpris-indicator-button
        blur-my-shell
        runcat
      ]);

      stateVersion = "22.05";
    };
    programs = {
      zsh = {
        enable = true;
        initExtra = ''
          [[ ! -f ~/.p10k/.p10k.zsh ]] || source ~/.p10k/.p10k.zsh
                  POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true'';
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
          theme = "robbyrussell";
        };
        shellAliases = { ls = "exa"; };
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

  # guest
  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "guests" ];
    home = "/home/guest";
    homeMode = "764";
    uid = 1001;
  };
}
