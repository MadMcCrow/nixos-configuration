# this is my base configuration for Nixos

{ config, pkgs, lib, ... }:

{

  # import
  imports = [
    ./hardware-configuration.nix
    ./user-configuration.nix
    ./flatpak-configuration.nix
  ];

  # Linux Kernel in use :
  boot.kernelPackages = pkgs.linuxPackages_zen;

  #UEFI
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 2;
  };
  boot.supportedFilesystems =
    [ "btrfs" "ext2" "ext3" "ext4" "f2fs" "fat8" "fat16" "fat32" ];

  # Networking
  networking.hostName = "nixAF"; # Define your hostname.
  networking.networkmanager.enable =
    true; # set networking.wireless.enable to use via wpa_supplicant instead.
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
    desktopManager.gnome.enable = true;
    libinput.enable = true;
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
    gnome.cheese
  ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  programs.dconf.enable = true;

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
  security.rtkit.enable = true; # rtkit is optional but recommended
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # root user
  users.users.root = {
    #home = "/home/root"; # this does not work
    homeMode = "700";
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    firefox
    nixfmt
    zsh
    oh-my-zsh
    nano
    htop
    neofetch
    wget
    git
    gh
    gcc
    clang
    lld
    gnumake
    cmake
    scons
    pkgconf
    libexecinfo
    xorg.libX11 # necessary to build godot [
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXi
    xorg.libXrandr # necessary to build godot ]
    xow_dongle-firmware # for xbox controller
  ];

  # Packages config
  nixpkgs.config = {
    allowUnfree = true;
    chromium = { enableWideVine = true; };
    packageOverrides = pkgs: {
      system-path =
        pkgs.system-path.override { xterm = pkgs.gnome.gnome-terminal; };
    };
  };

  # auto update
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    persistent = true;
  };

  # Nix
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Documentation
  documentation = {
    nixos.enable = true;
    man.enable = true;
    doc.enable = false;
  };

  # PowerManagement
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # GarbageCollection
  nix.gc = {
    automatic = true;
    dates = "daily";
  };

  # zsh
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      clean = "sudo nix-collect-garbage -d";
    };
  };

  # Faster boot:
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-fsck.enable = false;
  #  systemd.services.systemd-fsck@dev-disk-by\x2duuid-35d071fc\x2d963c\x2d4025\x2d8581\x2df023fbd936bd.enable = false;


  # Xbox Controller Support
  hardware.xone.enable = true;
  hardware.firmware = [ pkgs.xow_dongle-firmware ];
  
  # Steam hardware
  hardware.steam-hardware.enable = true;

  # etc/current-system-packages
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

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
  environment.etc."machine-id".source = "/nix/persist/etc/machine-id";

}
