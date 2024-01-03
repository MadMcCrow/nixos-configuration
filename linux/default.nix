# linux/default.nix
#	Nixos on linux
{ pkgs, config, lib, ... }:
with builtins;
let
  # shortcut
  cfg = config.nixos;

  # this flake
  flake = "MadMcCrow/nixos-configuration";
  updateDates = cfg.upgrade.updateDates;
  nixos-update = pkgs.writeShellApplication {
    name = "nixos-update";
    runtimeInputs = [ pkgs.nixos-rebuild ] ++ cfg.update.dependencies;
    text = ''
      if [ "$USER" != "root" ]; then
        echo "Please run nixos-update as root or with sudo"; exit 2
      fi
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake github:${flake}#
      exit $?
    '';
  };

  mkOptionBase = type: description: default:
    lib.mkOption { inherit type description default; };

  mkOptionDrv = desc: d: (mkOptionBase lib.types.package desc d);

  mkEnumOption = desc: list:
    lib.mkOption {
      description = (concatStringsSep "," [ desc "one of " (toString list) ]);
      type = lib.types.enum list;
      default = elemAt list 0;
    };

in {
  #interface
  options.nixos = with lib.types; {
    # this is for having a linux system
    enable = mkOptionBase bool "enable Nixos Linux" true;

    # HostName : (most important)
    host = {
      name = mkOptionBase str "hostname / computer name" "";
      id = mkOptionBase str "host unique ID - 8 hex digits"
        (elemAt (elemAt (split "(.{8})" (hashString "md5" cfg.host.name)) 1) 0);
    };

    # (auto-)Upgrade scheme :
    upgrade = {
      enable = mkOptionBase bool "enable auto upgrade" true;
      updateDates = lib.mkOption {
        type = types.str;
        default = "04:40";
        example = "daily";
        description = ''
          How often upgrade, optimize and garbage collection occurs.
          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };
      autoReboot = mkOptionBase bool "reboot post upgrade" true;
    };

    # manual update
    update.dependencies = mkOptionBase (listOf package) ''
      list of packages necessary for `nixos-update`
    '' [ ];
    update.extraCommands = mkOptionBase (listOf str) ''
      list of commands to run when doing manual update with `nixos-update`
    '' [ ];

    # nixos-rebuild
    rebuild = {
      genCount = lib.mkOption {
        default = 5;
        type = int;
        description = "number of generations to keep";
      };
    };

    # CPU/GPU
    cpu.vendor = mkEnumOption "CPU manufacturer" [ "amd" "intel" ];
    cpu.powermode =
      mkEnumOption "power governor" [ "ondemand" "powersave" "performance" ];
    gpu.enable = mkOptionBase bool "enable GPU support" true;
    gpu.vendor = mkEnumOption "GPU manufacturer" [ "amd" "intel" ];

    # audio (via piperwire as default)
    audio.enable = mkOptionBase bool "enable audio suppprt" true;
    audio.usePipewire = mkOptionBase bool "use pipewire" true;

    # TODO : add SE/Hardened linux support
    enhancedSecurity.enable = mkOptionBase bool "enable extra security" false;
    enhancedSecurity.appArmor.enable =
      mkOptionBase bool "enable App Armor, see https://www.apparmor.net/" true;

  };

  # imports
  imports =
    [ ./desktop ./server ./kernel.nix ./zfs.nix ./network.nix ./shell.nix ];

  # config
  config = lib.mkIf (cfg.enable) {

    # unique identifier for this machine
    networking.hostName = cfg.host.name;
    networking.hostId = cfg.host.id;

    nixos.kernel.modules =
      lib.lists.optional (cfg.gpu.vendor == "amd") "amdgpu";

    # Locale
    i18n.defaultLocale = "en_US.UTF-8";
    console.font = "Lat2-Terminus16";
    console.useXkbConfig = true; # use xkbOptions in tty.

    # Timezone
    time.timeZone = "Europe/Paris";
    services.timesyncd.servers = [ "fr.pool.ntp.org" "europe.pool.ntp.org" ];
    location.provider = "geoclue2"; # I don't want my address in this config

    # keyboard layout on desktop
    services.xserver = {
      enable = cfg.gpu.enable;
      videoDrivers = lib.lists.optional (cfg.gpu.vendor == "amd") "amdgpu";
      layout = "us";
      xkbVariant = "intl";
      xkbOptions = "eurosign:e";
    };

    # avahi for mdns :
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true; # ipv4
    services.avahi.nssmdns6 = true; # ipv6

    # env :
    environment = with pkgs; {
      # maybe use defaultPackages instead, because they might not be that necessary
      systemPackages = [
        lshw
        dmidecode
        pciutils
        usbutils
        psensor
        smartmontools
        lm_sensors
        eza
      ] ++ [ cachix vulnix ] ++ [ git git-crypt pre-commit git-lfs ]
        ++ [ nixos-update ] ++ [ age ]
        ++ (lib.lists.optionals cfg.gpu.enable [ vulkan-tools ])
        ++ (lib.lists.optionals cfg.enhancedSecurity.enable [ policycoreutils ])
        ++ (lib.lists.optionals (cfg.audio.enable && cfg.audio.usePipewire) [
          wireplumber
          helvum
        ]);

      # set env-vars here
      variables = lib.attrsets.optionalAttrs (cfg.gpu.vendor == "amd") {
        AMD_VULKAN_ICD = "RADV";
      };
    };

    # zsh can be used as default shell
    programs.zsh.enable = true;

    boot = {
      # hide wall-of-text
      plymouth.enable = true;

      # support everything
      supportedFilesystems = [
        "btrfs"
        "ext2"
        "ext3"
        "ext4"
        "f2fs"
        "fat8"
        "fat16"
        "fat32"
        "ntfs"
        "zfs"
      ];

      # UEFI boot loader with systemdboot
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = cfg.rebuild.genCount;
      };

      consoleLogLevel = 3; # avoid useless errors
    };

    # mount filesystems :
    # we try to always have boot as 8001-EF00
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-uuid/8001-EF00";
        fsType = "vfat";
      };
    };

    # nix setup
    nix = {
      # GarbageCollection
      gc = {
        automatic = true;
        dates = updateDates;
        persistent = true;
      };
      # detect files in the store that have identical contents,
      # and replaces them with hard links to a single copy.
      settings.auto-optimise-store = true;
      optimise.automatic = true;
      optimise.dates = [ updateDates ];
    };

    # root user
    users.users.root = {
      homeMode = "700"; # home will be erased anyway because on /
      hashedPassword =
        "$y$j9T$W.JAnia2yZEpLY8RwEJ4M0$eS3XjstDqU8/5gRoTHen9RDZg4E1XNKp0ncKxGs0bY.";
    };

    # PowerManagement
    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = cfg.cpu.powermode;

    # firmwares and drivers : CPU/GPU
    hardware = {
      enableRedistributableFirmware = true;
      cpu."${cfg.cpu.vendor}" = { updateMicrocode = true; };

      opengl = lib.mkIf cfg.gpu.enable {
        enable = true;
        # direct rendering (necessary for vulkan)
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs;
          (lib.lists.optionals (cfg.gpu.vendor == "intel") [
            intel-media-driver
            vaapiIntel
          ]) ++ [ libvdpau-va-gl vaapiVdpau ]
          ++ [ rocmPackages.clr rocmPackages.clr.icd ];
      };
    };

    systemd.tmpfiles.rules = lib.lists.optional (cfg.gpu.vendor == "amd")
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}";

    # AUDIO
    sound.enable = cfg.audio.enable
      && !cfg.audio.usePipewire; # disabled for pipewire
    hardware.pulseaudio.enable = cfg.audio.enable && !cfg.audio.usePipewire;
    security.rtkit.enable =
      cfg.audio.enable; # rtkit is optional but recommended
    services.pipewire = {
      enable = cfg.audio.usePipewire;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # app armor : https://wikipedia.org/wiki/AppArmor
    security.apparmor.enable = cfg.enhancedSecurity.enable
      && cfg.enhancedSecurity.appArmor;

    # Faster boot:
    systemd.services.NetworkManager-wait-online.enable =
      cfg.network.waitForOnline;
    systemd.services.systemd-fsck.enable = false;

    # upgrade automatically each day
    system.autoUpgrade = {
      flake = "github:${flake}";
      enable = cfg.upgrade.enable; # enable auto upgrades
      persistent = true; # apply if missed
      dates = cfg.upgrade.updateDates;
      allowReboot = cfg.upgrade.autoReboot;
    };

    # our configuration is working with "23.11"
    system.stateVersion = "23.11";

    # disable nixos manual : just use the web version !
    documentation.nixos.enable = false;
  };
}
