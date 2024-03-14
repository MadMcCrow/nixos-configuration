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

    # ZSH :
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      plugins = [{
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          hash = "";
        };
      }];
      history = {
        size = 100;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        share = true;
      };
      # alias vscodium to vscode
      shellAliases = {
        code = "codium";
        ls = "eza";
      };
      syntaxHighlighting.enable = true;
    };

    # eza is ls but improved
    programs.eza = {
      enable = true;
      # programs.eza.enableBashIntegration <- defaults to true
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
    programs.gh = {
      enable = true;
      settings.git_protocol = "https";
      extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
      gitCredentialHelper.enable = true;
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
