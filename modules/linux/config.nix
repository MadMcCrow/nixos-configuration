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
  nixpkgs,
  ...
}:
let
  cfg = config.nixos;
in
{
  # interface
  options.nixos =
    with lib;
    let
      mkDisableOption = d: mkEnableOption d // { default = true; };
      mkNonEmptyStrOption =
        description: default:
        mkOption {
          inherit description default;
          type = types.nonEmptyStr;
        };
    in
    {
      # just don't import if you don't want to enable !
      enable = mkDisableOption "nixos configuration";

      audio = {
        enable = mkDisableOption "audio support";
        # some intel drivers behave poorly so I left the ability to disable
        usePipewire = mkDisableOption "pipewire for audio";
      };

      # automatically wake-up computer on timer
      autowake = {
        enable = mkEnableOption "auto sleep/wake up timer";
        time = {
          sleep = mkNonEmptyStrOption "time to put to sleep" "22:00";
          wakeup = mkNonEmptyStrOption "time to wake up" "07:00";
        };
      };

      # create a service that will beep after successful boot
      # TODO : add more options for the pkgs.beep command
      beep.enable = mkEnableOption "make some noise when we boot successfully";

      # simplified filesystem setup : use install script to be helped with installation
      fileSystems =
        let
          mkuuidOption =
            name:
            mkOption {
              description = "${name} partition uuid";
              type =
                with types;
                nullOr (
                  addCheck str (s: (builtins.match "[a-zA-Z0-9\-]+" s) != null)
                );
            };
        in
        {
          # enable option
          enable = mkDisableOption "use default filesystems module";
          boot.partuuid = mkuuidOption "boot";
          swap.enable = mkDisableOption "enable swap partition";
          root = {
            partuuid = mkuuidOption "root";
            luks = {
              enable = mkDisableOption "use LUKS2 for root volume";
              name = mkNonEmptyStrOption "lvm partition name" "cryptroot";
            };
            lvm = {
              enable = mkEnableOption "use lvm on luks" // {
                defaults = config.nixos.fileSystems.volume.luks;
              };
              vgroup = mkNonEmptyStrOption "lvm volume group for nixos" "vg_nixos";
            };
          };
          # size of tmpfs for root
          tmpfsSize = mkOption {
            description = "Size of tmpfs for root";
            type = types.str;
            default = "2G";
          };
          persist = mkOption {
            description = "paths to make sure to persist";
            type = with types; attrsOf nonEmptyStr;
            default = { };
          };
          luks = mkOption {
            description = "devices to decrypt at boot";
            type = with types; attrsOf nonEmptyStr;
            default = { };
          };
        };

      # flatpak is supposed to be just a simple setting, 
      # but because of impermanence it may require extra-change
      flatpak.enable = mkEnableOption "flatpak software installation";

      # support for frenchness
      # TODO : maybe move to another sub-setting, it's kinda niche
      french.enable = mkDisableOption "french locale, paris timeclock, international keyboard config";

      # extra nix option for easier installation of software
      nix = {
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
      # read install.md to install secureboot
      secureboot.enable = mkDisableOption "secureboot for unlocking the luks device";

      # sleep support:
      sleep.enable = mkEnableOption "sleep mode support";
    };

  # implementation
  # TODO : maybe make mkDefault !
  config = lib.mkIf cfg.enable {
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
        luks.devices =
          (lib.attrsets.optionalAttrs cfg.fileSystems.enable {
            # support encryption and decryption at boot
            "${cfg.fileSystems.root.luks.name}" = {
              device = "/dev/disk/by-partuuid/${cfg.fileSystems.root.partuuid}";
              allowDiscards = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };
          })
          // (lib.attrsets.mapAttrs (_: v: {
            device = v;
            allowDiscards = true;
            crypttabExtraOpts = [ "tpm2-device=auto" ];
          }) cfg.fileSystems.luks);
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
        enable = lib.mkForce (!cfg.secureboot.enable);
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
    console = {
      inherit (config.fonts) packages;
      # font = config.fonts.fontconfig.defaultFonts.monospace;
      font = lib.mkIf cfg.french.enable "Lat2-Terminus16";
      useXkbConfig = true; # use xkbOptions in tty.
    };

    # everything needed to deal with encrypted file systems
    environment.defaultPackages = (
      with pkgs;
      config.fonts.packages
      ++ (lib.lists.optionals cfg.secureboot.enable [
        sbctl
        tpm-luks
        tpm2-tss
        nixos-enroll-tpm
      ])
      ++ [
        openssl
        ifwifi
        networkmanager
        dnsutils
        nmap
        ltunify # logitech unifying support
      ]
      ++ (lib.lists.optionals cfg.flatpak.enable [
        libportal
        libportal-gtk3
        packagekit
      ])
    );

    fileSystems = (
      let
        btrfsVolume = options: {
          device = "/dev/${cfg.fileSystems.root.lvm.vgroup}/nixos";
          fsType = "btrfs";
          inherit options;
        };
      in
      lib.mkIf cfg.fileSystems.enable {
        # /
        #   root is always tmpfs
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "size=${cfg.fileSystems.tmpfsSize}"
            "mode=755"
          ];
        };

        # /boot
        # Boot is always an Fat32 partition like old times
        "/boot" = {
          device = "/dev/disk/by-partuuid/${cfg.fileSystems.boot.partuuid}";
          fsType = "vfat";
        };

        # /nix
        #   Nix store and files
        #   more compression added to save space
        "/nix" = btrfsVolume [
          "subvol=/nix"
          "lazytime"
          "noatime"
          "compress=zstd:5"
        ];

        # /var/log
        # Logs and variable for running software
        # Limit disk usage with more compression
        # maybe move to /nix/persist ?
        "/var/log" = btrfsVolume [
          "subvol=/log"
          "compress=zstd:6" # higher level, default is 3
        ];

        # /tmp : cleared on boot, but on physical disk to avoid filling up ram
        "/tmp" = btrfsVolume [
          "subvol=/tmp"
          "lazytime"
          "noatime"
          "nodatacow" # no compression, but cleared on boot
        ];

        # /home
        #   TODO : maybe worth having setup elsewhere ?
        "/home" = btrfsVolume [
          "subvol=/home"
          "lazytime"
          "noatime"
          "compress=zstd"
        ];
      }
      // (lib.attrsets.mapAttrs'
        (n: v: {
          name = "/nix/persist/${n}";
          value = {
            device = v;
            options = [ "bind" ];
            neededForBoot = true;
            noCheck = true;
          };
        })
        (
          {
            "secureboot" = "/etc/secureboot";
            "ssh" = "/etc/ssh";
          }
          // cfg.fileSystems.persist
          // (lib.attrsets.optionalAttrs cfg.flatpak.enable {
            "flatpak" = "/var/lib/flatpak";
          })
        )
      )
    );

    # add all of our favorites fonts
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        noto-fonts
        open-sans
        roboto
        ubuntu_font_family
        jetbrains-mono
        nerdfonts
        terminus-nerdfont
        powerline-fonts
        fira-code-nerdfont
      ];
      fontconfig = {
        defaultFonts.monospace = map lib.getName [ pkgs.jetbrains-mono ];
        useEmbeddedBitmaps = true;
      };
    };

    hardware = {
      # disable pulseaudio if using pipewire 
      pulseaudio.enable = cfg.audio.enable && !cfg.audio.usePipewire;
    };

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
      config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;
      # each functions gets its pkgs from here :
      config.packageOverrides =
        pkgs:
        (lib.mkMerge (
          builtins.mapAttrs (_: value: (value pkgs)) cfg.overrides
        ));
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
        domainName = lib.mkIf (
          config.networking.domain != null
        ) config.networking.domain; # defaults to "local";
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

      # audio setup through pipewire
      pipewire = lib.mkIf (cfg.audio.enable && cfg.audio.usePipewire) {
        enable = true;
        package = pkgs.pipewire;
        # use pipewire for all audio streams
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # settings to detect and mount samba shares from windows
      samba-wsdd.workgroup = "WORKGROUP";

      # sync to those european servers
      timesyncd.servers = lib.mkIf cfg.french.enable [
        "fr.pool.ntp.org"
        "europe.pool.ntp.org"
      ];

      # keyboard settings for xserver
      xserver.xkb = lib.mkIf cfg.french.enable {
        layout = "us";
        variant = "intl";
        options = "eurosign:e";
      };
    };

    #
    security = {
      # lockKernelModules = true; # maybe too much !
      # Prevent kernel tampering
      protectKernelImage = true;
      # allow users to login via ssh
      pam.sshAgentAuth.enable = true;
      # required by pulseaudio and recommended for pipewire 
      rtkit.enable = cfg.audio.enable;
      # disable the sudo warnings about calling sudo
      # (it will get wiped every reboot)
      sudo.extraConfig = "Defaults        lecture = never";
      # add support for TPM2 
      tpm2 = {
        enable = true;
        pkcs11.enable = true;
      };
    };

    #nix update :
    system = {
      autoUpgrade = {
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
      userActivationScripts = lib.mkIf cfg.secureboot.enable {
        # this does not work because it requires a user to type the password
        # "enroll-tpm" = {
        #   text = "${lib.getExe nixos-enroll-tpm}";
        # };
      };
    };

    # enable or disable sleep/suspend
    systemd = {
      # TODO : make sleep a thing !
      targets = {
        sleep.enable = cfg.sleep.enable or cfg.autowake.enable;
        suspend.enable = cfg.sleep.enable;
        hibernate.enable = cfg.sleep.enable;
        hybrid-sleep.enable = cfg.sleep.enable;
      };

      services = {
        # beeps when we reach multi-user :
        "beep" = lib.mkIf cfg.beep.enable {
          after = [ "systemd-user-sessions.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe pkgs.beep;
          };
        };
        # wake up the computer at a certain time :
        "autowake" = lib.mkIf cfg.autowake.enable {
          restartIfChanged = false;
          stopIfChanged = false;

          startAt = cfg.autowake.time.sleep;
          # put to sleep until wake time :
          script = ''
            NEXT=$(systemd-analyze calendar "${cfg.autowake.time.wakeup}" | sed -n 's/\W*Next elapse: //p')
            AS_SECONDS=$(date +%s -d "$NEXT")
            echo "will wakeup on $(NEXT)"
            rtcwake -s $(AS_SECONDS)
          '';
        };
      };

      # Faster boot:
      network.wait-online.enable = true;
    };

    # some swap hardware :
    # swapDevices = lib.lists.optionals cfg.fileSystems.swap.enable [
    #   {
    #     label = "swap";
    #     device = lib.mkForce "/dev/${cfg.fileSystems.lvm.vgroup}/swap";
    #     randomEncryption = lib.mkIf (!cfg.fileSystems.root.luks.enable) {
    #       enable = true;
    #       allowDiscards = true;
    #     };
    #   }
    # ];

    networking = {
      # unique identifier for machines
      hostId =
        with builtins;
        elemAt (elemAt (split "(.{8})" (
          hashString "md5" config.networking.hostName
        )) 1) 0;
      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkForce true;
      enableIPv6 = true;
      dhcpcd.persistent = true;
      # nm is more convenient for now
      networkmanager.enable = true;
    };

    # language formats :
    # i18n =  ( lib.mkIf cfg.french.enable {
    #   defaultLocale = "en_US.UTF-8";
    #   supportedLocales = [
    #     "en_US.UTF-8"
    #     "fr_FR.UTF-8"
    #     "C.UTF-8"
    #   ];
    #   # set all the variable
    #   extraLocaleSettings = {
    #     # LC_ALL   = us-utf8;
    #     # LANGUAGE = us-utf8;
    #     LC_TIME = "fr_FR.UTF-8"; # use a reasonable date format
    #   };
    # });

    # time zone stuff :
    time.timeZone = lib.mkIf cfg.french.enable "Europe/Paris";
    location.provider = lib.mkDefault "geoclue2";

    # same GID for all SSH users
    users.groups.ssl-cert.gid = 119;

    # disable documentation (don't download, online is always up to date)
    documentation.nixos.enable = false;
  };
}
