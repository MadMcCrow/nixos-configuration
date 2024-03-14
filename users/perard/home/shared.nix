{ lib, pkgs, config, ... }: {

  # custom options
  options = with lib; {
    packages = {
      # nixpkgs.AllowUnfreePredicate
      unfree = mkOption {
        description = "list of unfree packages";
        type = types.listOf types.str;
        default = [ ];
      };
      # nixpkgs overlays
      overlays = mkOption {
        description = "list of overlays";
        type = types.listOf (mkOptionType {
          name = "nixpkgs-overlay";
          check = isFunction;
          merge = mergeOneOption;
        });
        default = [ ];
      };
    };
  };

  # enable HM
  config = {

    nixpkgs.overlays = config.packages.overlays;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.packages.unfree;

    programs.home-manager.enable = true;
    home.packages = (with pkgs; [
      powerline-go
      eza
      zsh-autosuggestions
      zsh-syntax-highlighting
      jetbrains-mono
      python3
      clang-tools_16
      git
      git-secrets
      git-credential-manager
    ]);

    # vs_code is in another module
    programs.vscode = (import ./vscode.nix { inherit pkgs; });

    # eza is ls but improved
    programs.eza = {
      enable = true;
      enableAliases = true;
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    # GIT
    programs.git = {
      enable = true;
      userName = "MadMcCrow";
      userEmail = "noe.perard+git@gmail.com";
      lfs.enable = true;
      extraConfig = {
        help.autocorrect = 10;
        color.ui = "auto";
        core.whitespace = "trailing-space,space-before-tab";
        apply.whitespace = "fix";
        credential.helper = "git-credential-manager";
      };
    };

    # bash is used in nix-shell
    programs.bash = {
      # enable powerline-go in bash
      bashrcExtra = ''
            # Workaround for nix-shell --pure
        if [ "$IN_NIX_SHELL" == "pure" ]; then
            if [ -x "$HOME/.nix-profile/bin/powerline-go" ]; then
                alias powerline-go="$HOME/.nix-profile/bin/powerline-go"
            elif [ -x "/run/current-system/sw/bin/powerline-go" ]; then
                alias powerline-go="/run/current-system/sw/bin/powerline-go"
            fi
        fi
      '';
    };

    # Bash And Zsh shell history suggest box
    programs.hstr.enable = true;

    # environment switcher
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    programs.powerline-go = {
      enable = true;
      modules = [ "user" "host" "nix-shell" "cwd" "gitlite" "root" ];
      modulesRight = [ "exit" "time" ];
      settings = {
        hostname-only-if-ssh = true;
        numeric-exit-codes = true;
        cwd-max-depth = 3;
        git-mode = "compact";
        priority = [ "root" "cwd" "user" "nix-shell" "gitlite" ];
      };
    };
  };
}
