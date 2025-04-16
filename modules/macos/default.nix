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
in
{

  # interface : a way to expose settings
  options.darwin = with lib; {
    sudoTouchIdAuth.enable =
      mkEnableOption ''
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
      unfreePackages = mkOption {
        description = "list of allowed unfree packages";
        type = with types; listOf str;
        default = [ ];
      };
      overlays = mkOption {
        description = "list of nixpks overlays";
        type = with types; listOf (mkOptionType {
          name = "nixpkgs-overlay";
          check = isFunction;
          merge = mergeOneOption;
        });
        default = [ ];
      };
      overrides = mkOption {
        description = "set of package overrides";
        default = { };
      };
    };
  };

  config = {

    # environment.pathsToLink = [ "/share/zsh" ];

    # Fonts
    fonts = {
      packages = with pkgs; [
        recursive
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
    };

    nix = {
      settings = {
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
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.packages.unfreePackages;

      # each functions gets its pkgs from here :
      config.packageOverrides =
        pkgs: (lib.mkMerge (builtins.mapAttrs (_: value: (value pkgs)) cfg.packages.overrides));
    };

    programs = {

      nix-index.enable = true;
      # fish not found command and extras
      # fish = {
      #  interactiveShellInit =
      #    if config.programs.fish.useBabelfish then
      #      ''
      #        function __fish_command_not_found_handler --on-event="fish_command_not_found"
      #            command_not_found_handle $argv
      #          end
      #      ''
      #    else
      #      ''
      #        function __fish_command_not_found_handler --on-event="fish_command_not_found"
      #          ${pkgs.bashInteractive}/bin/bash -c \
      #            "source ${cfg.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
      #        end
      #      '';
      # };
      # minimal zsh :
      zsh = {
        enable = true;
        enableCompletion = false;
      };
    };

    services = {
      nix-daemon.enable = true;
    };

    # PAM support
    system = {
      activationScripts = {
        # Following line should allow us to avoid a logout/login cycle
        postUserActivation.text = ''
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
      extraActivation = lib.mkIf cfg.sudoTouchIdAuth.enable {
        text =
          let
            file = "/etc/pam.d/sudo";
          in
          ''
            # PAM settings
              echo >&2 "enabling TouchId with pam..."
              if ! grep 'pam_tid.so' ${file} > /dev/null; then
                sed -i "" '2i\
              auth       sufficient     pam_tid.so # added by nix configuration
                ' ${file}
              fi
          '';
      };
      };
      keyboard.enableKeyMapping = true;
    };
  };

}
