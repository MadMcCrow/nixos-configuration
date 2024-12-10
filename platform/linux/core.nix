# /core.nix
# default system configuration.
#
# # Filesystems
# root on tmpfs uses around 11MB, what takes space is mostly /tmp.
# to avoid this issue, we have a filesystem dedicated to /tmp
# /var can also take a lot of space so we could move it to another filesystem
# we just focus on var/log because that could be useful to keep
# what's left is less than 1MB. 
# that's not the most optimized RAM setup, but I think all my machines can support losing that space.
# TLDR :
#   here's the layout :
#     - / -> tmpfs
#     - /var/log  -> btrfs, CoW disabled (no checksum)
#     - /nix      -> btrfs
#     - /tmp      -> btrfs, clean on boot, CoW disabled (no checksum)
#     - /home     -> btrfs
#
# # Networking
# We use network manager, avahi service detection. 
# Samba is set to work with Windows by default
# 
# # locale
# These machines are used by tasteful french users: us. Intl keyboard, but
# French timezone and time notation.
{
  lib,
  config,
  pkgs,
  ...
}:
let
  # shortcuts
  cfg = config.nixos;
  fls = cfg.fileSystems;
in
{
  # interface
  options.nixos = with lib; {
    nix = with lib; {
      # allow select unfree packages
      unfreePackages = mkOption {
        description = "list of allowed unfree packages";
        type = with lib.types; listOf str;
        default = [ ];
      };
      # overlays to add to nix
      overlays = mkOption {
        description = "list of nixpks overlays";
        type = types.listOf (mkOptionType {
          name = "nixpkgs-overlay";
          check = isFunction;
          merge = mergeOneOption;
        });
        default = [ ];
      };
    };

    fileSystems =
      let
        mkDeviceOption =
          mountpoint:
          mkOption {
            description = "block device for ${mountpoint}";
            type = with types; nullOr (addCheck str (s: (builtins.match "/dev/([a-zA-Z0-9]" s) != null));
          };
      in
      {
        # enable option
        enable = mkEnableOption "use default filesystems module";
        root = mkDeviceOption "btrfs volume";
        boot = mkDeviceOption "/boot UEFI partition";
        luks = mkEnableOption "use encryption for installation" // {
          default = true;
        };
        swap = mkEnableOption "enable swap partition" // {
          default = true;
        };
        volumeGroup = mkOption {
          description = "lvm volume group for nixos";
          type = types.str;
          default = "vg_nixos";
        };
        # size of tmpfs for root
        tmpfsSize = mkOption {
          description = "Size of tmpfs for root";
          type = types.str;
          default = "2G";
        };
        persist = mkOption {
          description = "list of path to make sure to persist";
          type = types.listOf types.str;
          default = [ ];
        };
      };

    secureboot = {
      enable = mkEnableOption ''secureboot for unlocking the luks device'' // {
        default = true;
      };
    };
    # support for frenchness
    # TODO : maybe move to another sub-setting, it's kinda niche
    french = mkEnableOption "french locale, paris timeclock, international keyboard config" // {
      default = true;
    };
  };

  # implementation
  # TODO : maybe make mkDefault !
  config = {
    #
    boot = {
      bootspec.enable = true;
      initrd = {
        # TODO : try later :
        # verbose = false;
        systemd = {
          enable = true; # TPM2 unlock
          network.wait-online.enable = config.nixos.server.enable;
        };
        inherit (config.boot) supportedFilesystems;
        luks.devices = lib.mkIf fls.enable {
          # support encryption and decryption at boot
          cryptroot = {
            device = fls.root;
            allowDiscards = true;
            crypttabExtraOpts = [ "tpm2-device=auto" ];
          };
        };
      };

      # support only what's necessary during the boot process
      supportedFilesystems = [
        "btrfs"
        "fat32"
      ];

      # clear tmp on boot
      tmp.cleanOnBoot = true;
      # choose correct bootloader :
      #   Lanzaboote currently replaces the systemd-boot module.
      loader.systemd-boot = {
        # enable if we're not using lanzaboote
        enable = lib.mkForce (!lanzaboote.enable);
        editor = false; # safety !
      };
      lanzaboote = {
        inherit (cfg.secureboot) enable;
        pkiBundle = "/etc/secureboot";
      };
      # clean boot process
      plymouth.enable = true; # hide wall-of-text
      consoleLogLevel = 3; # avoid useless errors
    };

    # font and use of keyboard options from the xserver
    console = lib.mkIf cfg.french {
      font = "Lat2-Terminus16";
      useXkbConfig = true; # use xkbOptions in tty.
    };

    # everything needed to deal with encrypted file systems
    environment.defaultPackages =
      with pkgs;
      (lib.lists.optionals cfg.secureboot.enable [
        sbctl
        tpm-luks
        tpm2-tss
        (writeShellApplication {
          name = "nixos-enroll-tpm";
          runtimeInputs = [ systemd ];
          text = lib.strings.concatMapStringsSep "\n" (
            device:
            "${systemd}/bin/systemd-cryptenroll  ${device} --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+1+7+11"
          ) (map (v: v.device) (builtins.attrValues config.boot.initrd.luks.devices));
        })
      ])
      // [
        openssl
        ifwifi
        networkmanager
        dnsutils
        nmap
      ]
      //
        # nixos script 
        [
          (writeShellApplication {
            name = "nixos-update";
            runtimeInputs = [ nixos-rebuild ];
            text = ''
              if [ -z "$1" ]
              then
                MODE=$1
              else
                MODE="switch"
              fi
              if [ "$USER" != "root" ]; then
                echo "Please run nixos-update as root or with sudo"; exit 2
              fi
              ${lib.getExe nixos-rebuild} "$MODE" \
              --flake ${config.system.autoUpgrade.flake}#${config.networking.hostName}
              exit $?
            '';
          })
        ];

    fileSystems =
      lib.mkIf fls.enable {
        # /boot
        # Boot is always an Fat32 partition like old times
        "/boot" = {
          device = fls.boot;
          fsType = "vfat";
        };

        # /
        #   root is always tmpfs
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "size=${fls.tmpfsSize}"
            "mode=755"
          ];
        };

        # /nix
        #   Nix store and files
        #   more compression added to save space
        "/nix" = {
          device = "/dev/${fls.volumeGroup}/nixos";
          fsType = "btrfs";
          options = [
            "subvol=/nix"
            "lazytime"
            "noatime"
            "compress=zstd:5"
          ];
        };

        # /var/log
        # Logs and variable for running software
        # Limit disk usage with more compression
        # maybe move to /nix/persist ?
        "/var/log" = {
          device = "/dev/${fls.volumeGroup}/nixos";
          fsType = "btrfs";
          options = [
            "subvol=/log"
            "compress=zstd:6" # higher level, default is 3
          ];
        };

        # /tmp : cleared on boot, but on physical disk to avoid filling up ram
        "/tmp" = {
          device = "/dev/${fls.volumeGroup}/nixos";
          fsType = "btrfs";
          options = [
            "subvol=/tmp"
            "lazytime"
            "noatime"
            "nodatacow" # no compression, but cleared on boot
          ];
        };

        # /home
        #   TODO : maybe worth having setup elsewhere ?
        "/home" = {
          device = "/dev/${fls.volumeGroup}/nixos";
          fsType = "btrfs";
          options = [
            "subvol=/home"
            "lazytime"
            "noatime"
            "compress=zstd"
          ];
        };
      }
      // listToAttrs (
        map
          (name: {
            inherit name;
            value = {
              device = ''/nix/persist/${lib.strings.removePrefix "/etc/" mountPoint}'';
              options = [ "bind" ];
              neededForBoot = true;
              noCheck = true;
            };
          })
          (
            [
              "/etc/secureboot"
              "/etc/ssh"
            ]
            ++ fls.persist
          )
      );

    # nix needs a lot of settings
    nix = {
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      registry.nixpkgs.flake = nixpkgs;
      package = pkgs.nix;
      settings = {
        # only sudo and root
        allowed-users = [ "@wheel" ];
        # enable flakes and commands
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # binary caches
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://nixos-configuration.cachix.org"
        ];
        # ssh keys of binary caches
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        # detect files in the store that have identical contents,
        # and replaces them with hard links to a single copy.
        auto-optimise-store = true;
      };

      # GarbageCollection
      gc = {
        automatic = true;
        dates = "daily";
        persistent = true;
      };
      optimise.automatic = true;
      optimise.dates = [ "daily" ];
      # serve nix store over ssh (the whole network can help each other)
      sshServe.enable = true;
    };

    nixpkgs = {
      # predicate from list
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;
      # each functions gets its pkgs from here :
      config.packageOverrides =
        pkgs: (lib.mkMerge (builtins.mapAttrs (n: value: (value pkgs)) cfg.overrides));
    };

    programs.nh = {
      enable = true;
      clean.enable = !config.nix.gc.automatic;
      clean.extraArgs = "--keep-since 4d --keep 3";
      # flake = "/home/user/my-nixos-config";
    };

    services = {
      # avahi for mdns :
      avahi = rec {
        enable = true;
        nssmdns4 = true;
        ipv6 = true;
        ipv4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          domain = true;
          workstation = true;
          userServices = true;
          addresses = true;
          hinfo = true;
        };
        # may prevent to detect samba shares
        domainName = lib.mkIf (config.networking.domain != null) config.networking.domain; # defaults to "local";
        browseDomains = [ domainName ];
      };

      # scrub-ba-dub-dub
      btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [
          "/nix"
          "/var/log"
          "/home" # maybe remove this when we move home
        ];
      };

      # thin provisioning for lvm
      lvm.boot.thin.enable = true;

      # remote shell via ssh
      openssh = {
        enable = true;
        # require public key authentication for better security
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
        };
        #permitRootLogin = "yes";
      };

      # settings to detect and mount samba shares from windows
      samba-wsdd.workgroup = "WORKGROUP";

      # sync to those european servers
      timesyncd.servers = lib.mkIf cfg.french [
        "fr.pool.ntp.org"
        "europe.pool.ntp.org"
      ];

      # keyboard settings for xserver
      xserver.xkb = lib.mkIf cfg.french {
        layout = "us";
        variant = "intl";
        options = "eurosign:e";
      };
    };

    security = {
      # disable the sudo warnings about calling sudo (it will get wiped every reboot)
      sudo.extraConfig = "Defaults        lecture = never";

      # allow users to login via ssh
      pam.sshAgentAuth.enable = true;

      # add support for TPM2 
      tpm2 = {
        enable = true;
        pkcs11.enable = true;
      };

      # Prevent kernel tampering
      #lockKernelModules = true; # maybe too much !
      protectKernelImage = true;
    };

    #nix update :
    system.autoUpgrade = {
      enable = true;
      operation = "boot"; # just upgrade :)
      flake = "github:MadMcCrow/nixos-configuration";
      # reboot at night :
      allowReboot = true;
      rebootWindow = {
        lower = "03:00";
        upper = "05:00";
      };
      # do it everyday
      persistent = true;
      dates = "daily";
    };

    # enable or disable sleep/suspend
    systemd = {
      # TODO : make sleep a thing !
      targets = lib.mkIf false {
        sleep.enable = cfg.sleep;
        suspend.enable = cfg.sleep;
        hibernate.enable = cfg.sleep;
        hybrid-sleep.enable = cfg.sleep;
      };

      # Faster boot:
      network.wait-online.enable = true;
    };

    # some swap hardware :
    swapDevices = lib.lists.optionals fls.swap [
      {
        label = "swap";
        device = lib.mkForce "/dev/${fls.volumeGroup}/swap";
        randomEncryption = lib.mkIf (!fls.luks.enable) {
          enable = true;
          allowDiscards = true;
        };
      }
    ];

    networking = {
      # unique identifier for machines
      hostId = elemAt (elemAt (split "(.{8})" (hashString "md5" config.networking.hostName)) 1) 0;
      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkForce true;
      enableIPv6 = true;
      dhcpcd.persistent = true;
      # nm is more convenient for now
      networkmanager.enable = true;
    };

    # language formats :
    i18n = lib.mkIf cfg.french {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8"
        "fr_FR.UTF-8"
        "C.UTF-8"
      ];
      # set all the variable
      extraLocaleSettings = {
        # LC_ALL   = us-utf8;
        # LANGUAGE = us-utf8;
        LC_TIME = "fr_FR.UTF-8"; # use a reasonable date format
      };
    };

    # time zone stuff :
    time.timeZone = lib.mkIf cfg.french "Europe/Paris";
    location.provider = lib.mkDefault "geoclue2";

    # same GID for all SSH users
    users.groups.ssl-cert.gid = 119;

    # disable documentation (don't download, online is always up to date)
    documentation.nixos.enable = false;
  };
}
