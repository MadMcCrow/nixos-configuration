# linux/default.nix
#	Nixos on linux
{ pkgs, config, lib, inputs, agenix, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.nixos;

  # submodules
  # (things to complicated or too specific to have directly in the default linux config)
  submodules = [ ./desktop ./server ];

  # helper functions
  mkEnableOptionDefault = desc: default:
    mkEnableOption (desc) // {
      inherit default;
    };
  mkStringOption = desc: default:
    mkOption {
      description = desc;
      inherit default;
      type = types.str;
    };
  mkStringsOption = desc: default:
    mkOption {
      description = desc;
      inherit default;
      type = types.listOf types.str;
    };
  mkDrvOption = desc: default:
    mkOption {
      description = desc;
      inherit default;
      type = types.package;
    };
  mkDrvsOption = desc: default:
    mkOption {
      description = desc;
      inherit default;
      type = types.listOf types.package;
    };
  mkEnumOption = desc: values:
    mkOption {
      description = concatStringsSep "," [ desc "one of " (toString values) ];
      type = types.enum values;
      default = elemAt values 0;
    };

  condAttr = s: a: d: if hasAttr a s then getAttr a s else d;
  condList = cond: value: if cond then value else [ ];
  condString = cond: value: if cond then value else "";
  vendorSwitch = s: v: l: d: err:
    if (any (x: x == v) l) then condAttr s v d else throw err;
  hashWithLength = str: len:
    elemAt (elemAt (split "(.{${toString len}})" (hashString "md5" str)) 1) 0;

  # ZFS
  ## rollback command
  zfsEnable = true; # cfg.zfs.enable;
  pl = cfg.zfs.rollback.pool;
  ds = cfg.zfs.rollback.dataset;
  sn = cfg.zfs.rollback.snapshot;
  rollbackCommand = "zfs rollback -r ${pl}/${ds}@${sn}";
  zfsModProbConfig = "options zfs l2arc_noprefetch=0 zfs_arc_max=1073741824";
  sysPool = cfg.zfs.systemPool;
  mkZFS = name: device: neededForBoot: {
    inherit name;
    value = {
      inherit device neededForBoot;
      mountPoint = name;
      fsType = "zfs";
    };
  };
  ZFSList = [
    (mkZFS "/" "${sysPool}/local/root" true)
    (mkZFS "/nix" "${sysPool}/local/nix" true)
    (mkZFS "/nix/persist" "${sysPool}/safe/persist" true)
    (mkZFS "/home" "${sysPool}/safe/home" false)
  ];
  zFileSystems = listToAttrs (if zfsEnable then ZFSList else [ ]);

  # Kernel
  defaultKernelMods = [
    "nvme"
    "xhci_pci"
    "xhci_hcd"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "dm-snapshot"
  ];
  kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  kernelParams = [ "nohibernate" "quiet" "idle=nomwait" ];

  # CPU
  # TODO : virtualisation
  cpuVendors = [ "amd" "intel" ];
  cpuVendorSwitch = s: d:
    vendorSwitch s cfg.cpu.vendor gpuVendors d "please define nixos.cpu.vendor";
  cpuVirtualisation = cpuVendorSwitch { "amd" = { }; } { };

  # GPU
  # TODO : Support multi-gpu
  gpuVendors = [ "amd" "intel" ];
  gpuVendorSwitch = s: d:
    vendorSwitch s cfg.gpu.vendor gpuVendors d "please define nixos.gpu.vendor";

  gpuKernelModule = gpuVendorSwitch { "amd" = [ "amdgpu" ]; } [ ];
  gpuOGLPackages = gpuVendorSwitch {
    "amd" = [ pkgs.amdvlk ];
    "intel" = [ pkgs.intel-media-driver pkgs.vaapiIntel ];
  } [ ];
  gpuDrivers = gpuVendorSwitch { "amd" = [ "amdgpu" "radeon" ]; } [ ];
  gpuVars = gpuVendorSwitch { "amd" = { AMD_VULKAN_ICD = "RADV"; }; } { };
  gpuTmpRules = gpuVendorSwitch {
    "amd" = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];
  } [ ];
  # TODO : intel override / overlay :
  gpuOverrides = gpuVendorSwitch {
    "intel" = {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  } { };

  vaapi = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  ocl = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];

  # updates:
  # this flake
  flake = "MadMcCrow/nixos-configuration";
  updateDates = cfg.upgrade.updateDates;
  # update command to always be right
  nixos-update = pkgs.writeShellScriptBin "nixos-update" ''
    if [ "$USER" != "root" ]
    then
      echo "Please run this as root or with sudo"
      exit 2
    fi
    nixos-rebuild switch --flake github:${flake}#
    exit $?
  '';

in {
  #interface
  options.nixos = {
    # this is for having a linux system
    enable = mkEnableOptionDefault "Nixos Linux" true;

    # HostName : (most important)
    host = {
      name = mkStringOption "hostname / computer name" "";
      id = mkStringOption "host unique ID - 8 hex digits"
        (hashWithLength cfg.host.name 8);
    };

    # (auto-)Upgrade scheme :
    upgrade = {
      enable = mkEnableOptionDefault "auto upgrade" true;
      updateDates = mkOption {
        type = types.str;
        default = "04:40";
        example = "daily";
        description = ''
          How often upgrade, optimize and garbage collection occurs.
          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };
      autoReboot = mkEnableOptionDefault "reboot post upgrade" true;
    };

    # ZFS file system specifics
    zfs = {
      enable = mkEnableOptionDefault "zfs filesystem" true;
      systemPool = mkStringOption "main system pool" "nixos-pool";
      rollback = {
        pool = mkStringOption "pool to rollback" "nixos-pool";
        dataset = mkStringOption "dataset to rollback" "local/root";
        snapshot = mkStringOption "snapshot for rollback" "blank";
      };
    };

    kernel = {
      packages = mkDrvOption "kernel packages" kernelPackages;
      extraKernelPackages = mkStringsOption "Extra kernel Packages" [ ];
      params = mkStringsOption "Extra kernel Params" [ ];
    };

    # nixos-rebuild
    rebuild = {
      genCount = mkOption {
        default = 5;
        type = types.int;
        description = "number of generations to keep";
      };
    };

    # printing
    CUPS = { enable = mkEnableOptionDefault "CUPS : printer support" false; };

    # CPU firmware and power settings
    cpu = {
      vendor = mkEnumOption "CPU manufacturer" cpuVendors;
      powermode = mkEnumOption "powergovernor mode" [
        "ondemand"
        "powersave"
        "performance"
      ];
    };

    # Graphics hardware settings
    gpu = {
      enable = mkEnableOptionDefault "GPU support" true;
      vendor = mkEnumOption "CPU manufacturer" gpuVendors;
    };

    # audio (via piperwire as default)
    audio = {
      enable = mkEnableOptionDefault "audio suppprt" true;
      usePipewire = mkEnableOptionDefault "pipewire" true;
    };

    # TODO : add SE/Hardened linux support
    enhancedSecurity = {
      enable = mkEnableOptionDefault "extra security" false;
      appArmor.enable =
        mkEnableOptionDefault "App Armor, see https://www.apparmor.net/" true;
    };

    network = {
      # systemd-networkd-wait-online can timeout and fail if there are no network interfaces available for it to manage.
      waitForOnline = mkEnableOptionDefault "wait for networking at boot" false;
      # useDHCP = mkEnableOptionDefault "use DHCP" true; # useless, just use dhcp with rooter configuration
      wakeOnLineInterfaces =
        mkStringsOption "Interfaces to enable wakeOnLan" [ ];
    };

  };

  # imports
  imports = submodules;

  # config
  config = mkIf cfg.enable {

    # Networking
    networking = {
      # unique identifier for this machine
      hostName = cfg.host.name;
      hostId = cfg.host.id;

      # use dhcp for addresses. static adresses are given by the rooter
      useDHCP = lib.mkDefault true;
      enableIPv6 = true;

      networkmanager.enable = true;
      firewall.allowedTCPPorts = [ 22 ];

      interfaces = listToAttrs (map (x: {
        name = "${x}";
        value = { wakeOnLan.enable = true; };
      }) cfg.network.wakeOnLineInterfaces);
    };

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
      videoDrivers = gpuDrivers;
      layout = "us";
      xkbVariant = "intl";
      xkbOptions = "eurosign:e";
    };

    # CUPS printer support :
    services.printing = {
      enable = cfg.CUPS.enable; # default to false
      #stateless = true;
      #drivers = [ ];
    };

    # zfs
    services.zfs = {
      trim.enable = zfsEnable;
      autoScrub.enable = zfsEnable;
    };

    # avahi for mdns :
    services.avahi = {
      enable = true;
      nssmdns = true;
    };
    # env :
    environment = with pkgs; {
      # maybe use defaultPackages instead, because they might not be that necessary
      systemPackages = [ pciutils usbutils psensor lm_sensors exa ]
        ++ [ cachix vulnix ] ++ [ git git-crypt pre-commit git-lfs ]
        ++ [ nixos-update ] ++ [ agenix.packages.x86_64-linux.default age ]
        ++ (condList cfg.gpu.enable [ vulkan-tools ])
        ++ (condList cfg.enhancedSecurity.enable [ policycoreutils ]);

      # set env-vars here
      variables = gpuVars;

      # keep secrets
      persistence."/nix/persist" = { directories = [ "/etc/nixos/secrets" ]; };
    };

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

      initrd = {
        # use availableKernelModules to avoid force loading them
        kernelModules = defaultKernelMods;
        postDeviceCommands = lib.mkAfter rollbackCommand;
      };

      # Kernel Packages
      inherit kernelPackages;
      extraModulePackages =
        map (x: kernelPackages."${x}") cfg.kernel.extraKernelPackages;

      # UEFI boot loader with systemdboot
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = cfg.rebuild.genCount;
      };

      # add zfs modprobe
      extraModprobeConfig =
        mkAfter (if zfsEnable then zfsModProbConfig else "");

      # import zfs pools at boot
      zfs = {
        forceImportRoot = zfsEnable;
        forceImportAll = zfsEnable;
        enableUnstable = false;
      };

      # boot kernel params
      kernelParams = cfg.kernel.params ++ kernelParams;
      consoleLogLevel = 3; # avoid useless errors
    };

    # mount filesystems
    fileSystems = zFileSystems // {
      "/boot" = {
        device = "/dev/disk/by-uuid/8001-EF00";
        fsType = "vfat";
      };
    };

    # nix setup
    nix = {

      package = pkgs.nixVersions.unstable;
      extraOptions = "experimental-features = nix-command flakes";

      # GarbageCollection
      gc = {
        automatic = true;
        dates = updateDates;
        persistent = true;
      };

      # detect files in the store that have identical contents, and replaces them with hard links to a single copy.
      settings.auto-optimise-store = true;

      # automate optimising the store :
      optimise = {
        automatic = true;
        dates = [ updateDates ];
      };

      # add support for cachix
      settings = {
        substituters = [
          "https://nixos-configuration.cachix.org"
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # root user
    users.users.root = {
      homeMode = "700"; # home will be erased anyway because on /
      hashedPassword =
        "$y$j9T$W.JAnia2yZEpLY8RwEJ4M0$eS3XjstDqU8/5gRoTHen9RDZg4E1XNKp0ncKxGs0bY.";
    };

    # PowerManagement
    powerManagement = {
      enable = true;
      cpuFreqGovernor = cfg.cpu.powermode;
    };

    # firmwares and drivers : CPU/GPU
    hardware = {
      enableRedistributableFirmware = true;
      cpu."${cfg.cpu.vendor}" = { updateMicrocode = true; };

      opengl = mkIf cfg.gpu.enable {
        enable = true;
        # direct rendering (necessary for vulkan)
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = gpuOGLPackages ++ vaapi ++ ocl;
      };
    };
    systemd.tmpfiles.rules = gpuTmpRules;

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
    systemd.services = {
      NetworkManager-wait-online.enable = cfg.network.waitForOnline;
      systemd-fsck.enable = false;
    };

    system = {

      # script activated
      activationScripts = {

        #
        # We get all the secrets for the config and (re-)generate them
        # if not present or cannot be opened
        #
        secrets = let
          key = elemAt config.age.identityPaths 0;
          secrets = map (x: x.file) (attrValues config.age.secrets);
          secretsStr = concatStringsSep "\n" secrets;
        in {
          text = ''
            if [ ! -f ${key} ]; then
                echo "SSH key not found at $''${key}. Creating a new one..."
                ssh-keygen -C ${key} -f "./$''${key}" -q
            fi
            SECRETS=${secretsStr}

            for SECRET_FILE_LOCATION in "$@"; do
                if [ -f "$SECRET_FILE_LOCATION" ]; then
                    echo "Secret file found at $SECRET_FILE_LOCATION. Trying to open it..."
                    if ${pkgs.age} -d -i ${key} -o "$SECRET_FILE_LOCATION"; then
                        echo "Success! Here is the content of the secret file:"
                        cat "$SECRET_FILE_LOCATION"
                    else
                        echo "Failed to open the secret file. Deleting and recreating it..."
                        rm "$SECRET_FILE_LOCATION"
                        ${pkgs.age} -i ${key} -o "$SECRET_FILE_LOCATION"
                    fi
                else
                    echo "Secret file not found at $SECRET_FILE_LOCATION. Creating a new one..."
                    ${pkgs.age} -i ${key} -o "$SECRET_FILE_LOCATION"
                fi
            done
          '';
        };

      };

      # upgrade automatically each day
      autoUpgrade = {
        flake = "github:${flake}";
        enable = cfg.upgrade.enable; # enable auto upgrades
        persistent = true; # apply if missed
        dates = cfg.upgrade.updateDates;
        allowReboot = cfg.upgrade.autoReboot;
      };

      # our configuration is working with "23.05"
      stateVersion = "23.05";
    };

    # disable nixos manual : just use the web version !
    documentation.nixos.enable = false;
  };
}
