# this is my base configuration for Nixos

{ config, pkgs, lib, ... }:

{
 
  # import
  imports = [./hardware-configuration.nix ./user-configuration.nix ./flatpak-configuration.nix];
 
  #UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" "ext2" "ext3" "ext4" "f2fs" "fat8" "fat16" "fat32" ];

  # Networking
  networking.hostName = "nixAF"; # Define your hostname.
  networking.networkmanager.enable = true;  #  set networking.wireless.enable to use via wpa_supplicant instead.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false; # disable the firewall altogether
  
  # Timezone
  time.timeZone = "Europe/Paris";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
     font = "Lat2-Terminus16";
     useXkbConfig = true; # use xkbOptions in tty.
  };

  # Wayland
  services.xserver = {
	enable = true;
	excludePackages = [ pkgs.xterm ];
	desktopManager.xterm.enable = false;
	displayManager.gdm.enable = true;
	displayManager.gdm.wayland = true;
	displayManager.autoLogin.enable = false;
	#displayManager.autoLogin.user = "perard";
	desktopManager.gnome.enable = true;
	#libinput.enable = true;  # Enable touchpad support (enabled default in most desktopManager).
  };
  
  # Gnome40
  environment.gnome.excludePackages = with pkgs; [
  gnome.gnome-weather
  gnome-tour
  gnome-photos
  gnome.simple-scan 
  gnome.gnome-music
  gnome.epiphany
  gnome.totem
  gnome.yelp
  ];


  # Configure keymap in X11
  services.xserver = {
     layout = "us";
     xkbVariant = "intl";
     xkbOptions = "eurosign:e";
  };  
  
  # CUPS
  services.printing.enable = false;

  # Sound
  sound.enable = false; # disabled for pipewire
  hardware.pulseaudio.enable = false; # disabled for pipewire
  security.rtkit.enable = true;   # rtkit is optional but recommended
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # root user
  users.users.root.initialHashedPassword = "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  
  # Packages
  environment.systemPackages = with pkgs; [
     firefox
     oh-my-zsh
     zsh
     nano
     wget
     git
     gcc
     clang
     lld
     scons
     pkgconf
     libexecinfo
     xorg.libX11
     xorg.libXcursor
     xorg.libXinerama
     xorg.libXi
     xorg.libXrandr
   ];
   
  # Packages config
  nixpkgs.config = {
   allowUnfree = true;
   chromium = {
     enableWideVine = true;
    };
   packageOverrides = pkgs: {
        system-path = pkgs.system-path.override {
            xterm = pkgs.gnome.gnome-terminal;
        };
    };
  };
    
  # auto update
  system.autoUpgrade.enable = true;
  
  # Nix
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Git
  programs.git = {
    enable = true;
  };
  
  # Zsh
  programs.zsh = {
 enable = true;
 syntaxHighlighting.enable = true;
 autosuggestions.enable = true;
   shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch";
  };
 interactiveShellInit = ''
   export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
   export FZF_BASE=${pkgs.fzf}/share/fzf/
   # Customize your oh-my-zsh options here
   ZSH_THEME="robbyrussell"
   plugins=(git fzf )
   HISTFILESIZE=500000
   HISTSIZE=500000
   setopt SHARE_HISTORY
   setopt HIST_IGNORE_ALL_DUPS
   setopt HIST_IGNORE_DUPS
   setopt INC_APPEND_HISTORY
   autoload -U compinit && compinit
   unsetopt menu_complete
   setopt completealiases
   if [ -f ~/.aliases ]; then
     source ~/.aliases
   fi
   source $ZSH/oh-my-zsh.sh
 '';
 promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
 };
  users.defaultUserShell = pkgs.zsh;
  
  # Documentation
  documentation = {
  	nixos.enable = true;
  	man.enable = true;
  	doc.enable = false;
  	};
  
  
  # etc/current-system-packages
  environment.etc."current-system-packages".text =
  let
  packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
  sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
  formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
  formatted;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Default settings (no edit)

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  
  # machine-id is used by systemd for the journal, if you don't
  # persist this file you won't be able to easily use journalctl to
  # look at journals for previous boots.
  environment.etc."machine-id".source
    = "/nix/persist/etc/machine-id";
  
}
