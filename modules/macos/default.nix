# default.nix
#	Base of modules
{
  pkgs,
  config,
  lib,
  nixpkgs,
  ...
}:
let
  # shortcut
  cfg = config.darwin;

  # optiontype for overlays
  overlaysType =
    with lib;
    let
      subType = mkOptionType {
        name = "nixpkgs-overlay";
        check = isFunction;
        merge = mergeOneOption;
      };
    in
    types.listOf subType;

  # init for fish and "command not found"
  fishInit =
    if config.programs.fish.useBabelfish then
      ''
        command_not_found_handle $argv
      ''
    else
      ''
        ${pkgs.bashInteractive}/bin/bash -c \
          "source ${cfg.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
      '';

  # We don't use `environment.etc` because this would require that the user manually delete
  # `/etc/pam.d/sudo` which seems unwise given that applying the nix-darwin configuration requires
  # sudo. We also can't use `system.patchs` since it only runs once, and so won't patch in the
  # changes again after OS updates (which remove modifications to this file).
  #
  # As such, we resort to line addition/deletion in place using `sed`. We add a comment to the
  # added line that includes the name of the option, to make it easier to identify the line that
  # should be deleted when the option is disabled.
  mkSudoTouchIdAuthScript =
    isEnabled:
    let
      file = "/etc/pam.d/sudo";
      option = "security.pam.enableSudoTouchIdAuth";
    in
    ''
      ${
        if isEnabled then
          ''
            # Enable sudo Touch ID authentication, if not already enabled
            if ! grep 'pam_tid.so' ${file} > /dev/null; then
              sed -i "" '2i\
            auth       sufficient     pam_tid.so # nix-darwin: ${option}
              ' ${file}
            fi
          ''
        else
          ''
            # Disable sudo Touch ID authentication, if added by nix-darwin
            if grep '${option}' ${file} > /dev/null; then
              sed -i "" '/${option}/d' ${file}
            fi
          ''
      }
    '';

in
{

  # interface : a way to expose settings
  options.darwin = with lib; {
    enable = mkEnableOption "nix-darwin" // {
      default = true;
    };

    sudoTouchIdAuth.enable =
      lib.mkEnableOption ''
        sudo authentication with Touch ID
        When enabled, this option adds the following line to /etc/pam.d/sudo:
            auth       sufficient     pam_tid.so
        (Note that macOS resets this file when doing a system update. As such, sudo
        authentication with Touch ID won't work after a system update until the nix-darwin
        configuration is reapplied.)
      ''
      // {
        defaults = true;
      };

    packages = {
      # allow select unfree packages
      unfreePackages = lib.mkOption {
        description = "list of allowed unfree packages";
        type = with lib.types; listOf str;
        default = [ ];
      };
      overlays = lib.mkOption {
        description = "list of nixpks overlays";
        type = overlaysType;
        default = [ ];
      };
      overrides = lib.mkOption {
        description = "set of package overrides";
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Fonts
    fonts = {
      packages = with pkgs; [
        recursive
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
    };

    nix = {
      # pin for nix2
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      # pin for nix3
      registry.nixpkgs.flake = nixpkgs;

      package = pkgs.nix;

      settings = {
        # keep flake and commands
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # cache providers
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org/"
          "https://nixos-configuration.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-configuration.cachix.org-1:dmaMl2SX7/VRV1qAQRntZaNEkRyMcuqjb7H+B/2jlF0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # TODO MAYBE ONLY HAVE @admin
        trusted-users = [ "@admin" ];
        allowed-users = [ "@wheel" ];

      };

      optimise.automatic = true;

      # GarbageCollection
      gc.automatic = true;

      # redo what's in settings + add x86 to M1 macs
      extraOptions =
        ''
          experimental-features = nix-command flakes
        ''
        + lib.optionalString (pkgs.system == "aarch64-darwin") ''
          extra-platforms = x86_64-darwin aarch64-darwin
        '';
    };

    nixpkgs = {
      #  # merged overlays
      #  overlays = cfg.packages.overlays // {
      #    # Overlay useful on Macs with Apple Silicon
      #    apple-silicon = final: prev:
      #      (prev.stdenv.system == "aarch64-darwin") {
      #        # Add access to x86 packages if system is running Apple Silicon
      #        pkgs-x86 = import inputs.nixpkgs {
      #          system = "x86_64-darwin";
      #          inherit (inputs.nixpkgs) config;
      #        };
      #      };
      #  };

      # predicate from list
      config.allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) cfg.packages.unfreePackages;

      # each functions gets its pkgs from here :
      config.packageOverrides =
        pkgs:
        (lib.mkMerge (
          builtins.mapAttrs (_: value: (value pkgs)) cfg.packages.overrides
        ));
    };

    programs = {

      nix-index.enable = true;

      # fish not found command and extras
      fish.interactiveShellInit = ''
        function __fish_command_not_found_handler --on-event="fish_command_not_found"
          ${fishInit}
        end
      '';
      zsh.enable = true;

    };

    services = { 
      nix-daemon.enable = true; 
    };

    # PAM support
    system.activationScripts.extraActivation =
      lib.mkIf cfg.sudoTouchIdAuth.enable
        {
          text = ''
            # PAM settings
            echo >&2 "setting up pam..."
            ${mkSudoTouchIdAuthScript cfg.enable}
          '';
        };
  };

}
