# home.nix
# home manager configuration for user
{ config, pkgs, lib, ... }: {

  # add our dconf settings
  imports = [ ./dconf.nix ./shared.nix ./games.nix ];

  config = {
    home.username = "perard";
    home.homeDirectory = "/home/perard";
    home.stateVersion = "23.11";

    # packages to install to profile
    home.packages = (with pkgs; [ eza speechd bitwarden discord nss_latest ]);

    # vscode is in another module (too many extensions)
    programs.vscode = (import ./vscode.nix { inherit pkgs; });

    # FIREFOX
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "https";
      extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
      gitCredentialHelper.enable = true;
    };
    programs.git-credential-oauth.enable = true;

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
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
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
      shellAliases = { code = "codium"; };
      syntaxHighlighting.enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
    };

    # Bash And Zsh shell history suggest box
    programs.hstr.enable = true;

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

    # eza is ls but improved
    programs.eza = {
      enable = true;
      enableAliases = true;
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    packages.overlays = [
      (self: super: {
        discord = super.discord.override { withOpenASAR = true; };
      })
    ];
    packages.unfree = [ "discord" ];

  };

}
