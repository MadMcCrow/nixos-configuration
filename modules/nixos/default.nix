# linux/default.nix
#	Nixos on linux
{ pkgs, config, lib, inputs, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.nixos;

  # submodules 
  # (things to complicated or too specific to have directly in the default linux config)
  submodules = [ ./desktop ./server];

  # helper functions
  mkEnableOptionDefault = desc: default:
    mkEnableOption (mdDoc desc) // {
      inherit default;
    };
  mkStringOption = desc: default:
    mkOption {
      description = mdDoc desc;
      inherit default;
      type = types.str;
    };
  mkStringsOption = desc: default:
    mkOption {
      description = mdDoc desc;
      inherit default;
      type = types.listOf types.str;
    };
  mkDrvOption = desc: default:
    mkOption {
      description = mdDoc desc;
      inherit default;
      type = types.package;
    };
  mkDrvsOption = desc: default:
    mkOption {
      description = mdDoc desc;
      inherit default;
      type = types.listOf types.package;
    };
  mkEnumOption = desc: values:
    mkOption {
      description =
        mdDoc (concatStringsSep "," [ desc "one of " (toString values) ]);
      type = types.enum values;
      default = elemAt values 0;
    };
  condAttr = s : a : d: if hasAttr a s then getAttr a s else d; 
  condList = cond: value: if cond then value else [ ];
  condString = cond: value: if cond then value else "";
  vendorSwitch  = s : v : l : d : err: if (any (x : x == v) l) then condAttr s v d else throw err; 
  hashWithLength = str : len : elemAt (elemAt (split "(.{${toString len}})" (hashString "md5" str)) 1) 0;

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
    (mkZFS "/persist" "${sysPool}/safe/persist" true)
    (mkZFS "/home" "${sysPool}/safe/home" false)
  ];
  zFileSystems = listToAttrs (if zfsEnable then ZFSList else []);

  # Kernel
  defaultKernelMods =
    [ "nvme" "xhci_pci" "xhci_hcd" "ahci" "usbhid" "usb_storage" "sd_mod" "dm-snapshot" ];
  kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  kernelParams = [ "nohibernate" "quiet" "loglevel=3" ];


  # CPU
  # TODO : virtualisation
  cpuVendors = ["amd" "intel"];
  cpuVendorSwitch = s: vendorSwitch s cfg.cpu.vendor gpuVendors []  "please define nixos.cpu.vendor";
  cpuVirtualisation = cpuVendorSwitch {"amd" = {};};

  # GPU
  # TODO : Support multi-gpu
  gpuVendors = ["amd" "intel"];
  gpuVendorSwitch = s: vendorSwitch s cfg.gpu.vendor gpuVendors []  "please define nixos.gpu.vendor";

  gpuKernelModule = gpuVendorSwitch { "amd" =  ["amdgpu"]; };
  gpuOGLPackages  = gpuVendorSwitch {"amd" = [pkgs.amdvlk]; "intel" = [ pkgs.intel-media-driver pkgs.vaapiIntel];};
  gpuDrivers      = gpuVendorSwitch { "amd" =  ["amdgpu" "radeon"]; };
  gpuVars         = gpuVendorSwitch { "amd" = {AMD_VULKAN_ICD = "RADV";};};
  gpuTmpRules     = gpuVendorSwitch { "amd" =  ["L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"]; };
  # TODO : intel override / overlay :    
  gpuOverrides   = gpuVendorSwitch { "intel" = {vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };};};

  vaapi = with pkgs; [libvdpau-va-gl vaapiVdpau];
  ocl   = with pkgs; [rocm-opencl-icd rocm-opencl-runtime];


  # update date:
  updateDates = cfg.upgrade.updateDates;

in {
  #interface
  options.nixos = {
    # this is for having a linux system
    enable = mkEnableOptionDefault "Nixos Linux" true;

    # HostName : (most important)
    host = {
      name = mkStringOption "hostname / computer name" "";
      id   = mkStringOption "host unique ID - 8 hex digits" (hashWithLength cfg.host.name 8);
    };

    # (auto-)Upgrade scheme :
    upgrade = {
      enable = mkEnableOptionDefault "auto upgrade" true;
      updateDates = mkOption {
        type = types.str;
        default = "04:40";
        example = "daily";
        description = lib.mdDoc ''
          How often upgrade, optimize and garbage collection occurs.
          The format is described in
          {manpage}`systemd.time(7)`.
        '';
      };
      autoReboot = mkEnableOptionDefault  "reboot post upgrade" true;
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
      params = mkStringsOption "Extra kernel Params" kernelParams;
    };

    # nixos-rebuild
    rebuild = {
      genCount = mkOption {
        default = 5;
        type = types.int;
        description = (mdDoc "number of generations to keep");
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
      appArmor.enable = mkEnableOptionDefault "App Armor, see https://www.apparmor.net/" true;
    };

    network = {
      # systemd-networkd-wait-online can timeout and fail if there are no network interfaces available for it to manage. 
      waitForOnline = mkEnableOption (mdDoc "wait for networking at boot");
      useDHCP = mkEnableOptionDefault "use DHCP" true;
    };

  }; 

  # imports
  imports = submodules;

  # config
  config = mkIf cfg.enable {

    # Networking
    networking.hostName = cfg.host.name;
    networking.networkmanager.enable = true;
    networking.hostId = cfg.host.id;
 #   networking.useDHCP = lib.mkDefault cfg.networkuseDHCP;

    # Locale
    i18n.defaultLocale = "en_US.UTF-8";
    console.font = "Lat2-Terminus16";
    console.useXkbConfig = true; # use xkbOptions in tty.

   # Timezone
    time.timeZone = "Europe/Paris";
    services.timesyncd.servers = [ "fr.pool.ntp.org" "europe.pool.ntp.org" ];

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

    # env :
    environment = with pkgs; {
      # maybe use defaultPackages instead, because they might not be that necessary
      systemPackages = [ git git-crypt cachix vulnix  pciutils usbutils psensor lm_sensors age ]  ++  
                       (condList cfg.gpu.enable [ vulkan-tools ]) ++
                       (condList cfg.enhancedSecurity.enable [policycoreutils]);

      # set env-vars here
      variables = gpuVars;
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
      extraModulePackages = map (x: kernelPackages."${x}") cfg.kernel.extraKernelPackages;

      # UEFI boot loader with systemdboot
      loader = {
        systemd-boot.enable = true; # use gummyboot for faster boot
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = cfg.rebuild.genCount;
      };

      # add zfs modprobe
      extraModprobeConfig = mkAfter (if zfsEnable then zfsModProbConfig else "");

      # import zfs pools at boot
      zfs = {
        forceImportRoot = zfsEnable;
        forceImportAll = zfsEnable;
        enableUnstable = false;
      };

      # boot kernel params
      kernelParams = cfg.kernel.params;
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
        dates = [updateDates ];
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
        "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    };

    # PowerManagement
    powerManagement = {
      enable = true;
      powertop.enable = true;
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
        extraPackages =  gpuOGLPackages ++ vaapi ++ ocl;
        };
    };
    systemd.tmpfiles.rules = gpuTmpRules;

    # AUDIO
    sound.enable = cfg.audio.enable && !cfg.audio.usePipewire; # disabled for pipewire
    hardware.pulseaudio.enable = cfg.audio.enable && !cfg.audio.usePipewire;
    security.rtkit.enable = cfg.audio.enable; # rtkit is optional but recommended
    services.pipewire = {
      enable = cfg.audio.usePipewire;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # app armor : https://wikipedia.org/wiki/AppArmor
    security.apparmor.enable = cfg.enhancedSecurity.enable && cfg.enhancedSecurity.appArmor;

    # Faster boot:
    systemd.services = {
      NetworkManager-wait-online.enable = cfg.network.waitForOnline;
      systemd-fsck.enable = false;
    };

    system = {
      autoUpgrade = {
        enable = cfg.upgrade.enable; # enable auto upgrades
        persistent = true; # apply if missed
        flake = "github:MadMcCrow/nixos-configuration"; # this flake
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
