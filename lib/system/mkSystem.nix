# mkSystem.nix
#   base function to build an host
# returns :
#   all the meaningful outputs
{ nixpkgs, ... }@args:
let

  mkConfig = import ./mkConfig.nix args;

  nixosSystem = tomlPath: (lib.nixosSystem (mkConfig tomlPath));

  # lib.nixosSystem outputs
  # [
  #   "_module"
  #   "_type"
  #   "class"
  #   "config"
  #   "extendModules"
  #   "extraArgs"
  #   "graph"
  #   "lib"
  #   "options"
  #   "pkgs"
  #   "type"
  # ]

  # (lib.nixosSystem ).config.system
  # [
  #   "activatable"
  #   "activatableSystemBuilderCommands"
  #   "activationScripts"
  #   "autoUpgrade"
  #   "boot"
  #   "build"
  #   "checks"
  #   "configurationRevision"
  #   "copySystemConfiguration"
  #   "defaultChannel"
  #   "disableInstallerTools"
  #   "dryActivationScript"
  #   "etc"
  #   "extraDependencies"
  #   "extraSystemBuilderCmds"
  #   "forbiddenDependenciesRegex"
  #   "forbiddenDependenciesRegexes"
  #   "fsPackages"
  #   "image"
  #   "includeBuildDependencies"
  #   "modulesTree"
  #   "name"
  #   "nixos"
  #   "nixos-generate-config"
  #   "nixos-init"
  #   "nixosLabel"
  #   "nixosRevision"
  #   "nixosVersion"
  #   "nixosVersionSuffix"
  #   "nssDatabases"
  #   "nssHosts"
  #   "nssModules"
  #   "path"
  #   "preSwitchChecks"
  #   "preSwitchChecksScript"
  #   "rebuild"
  #   "replaceDependencies"
  #   "replaceRuntimeDependencies"
  #   "requiredKernelConfig"
  #   "services"
  #   "stateVersion"
  #   "switch"
  #   "systemBuilderArgs"
  #   "systemBuilderCommands"
  #   "tools"
  #   "userActivationScripts"
  # ]

  outputs = with nixosSystem.config.system.build; [
    diskoScript
    toplevel
    installBootLoader
  ];

in nixosSystem.pkgs.runCommand "system-${nixosSystem.config.networking.hostName}" {} ''
     mkdir -p $out

     ${lib.concatStringsSep "\n"
       (lib.mapAttrsToList (name: drv: ''
         ln -s ${drv} $out/${name}
       '') outputs)}
   ''
