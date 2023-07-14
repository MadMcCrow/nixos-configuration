# home.nix
# home manager configuration for user
{ config, pkgs, ... }:
let
  # true if this program can work
  supported = package: builtins.elem pkgs.system package.meta.platforms;
in {

  home.username = "perard";
  home.homeDirectory = "/home/perard";
  home.stateVersion = "23.05";

  # add our dconf settings
  imports = [ ./dconf.nix ];

  # packages to install to profile
  home.packages = with pkgs; [
    git
    gh
    exa
    powerline-go
    zsh-autosuggestions
    zsh-syntax-highlighting
    jetbrains-mono
  ];

  # enable HM
  programs.home-manager.enable = true;

  # Programs setup :
  # vscode is in another module (too many extensions)
  programs.vscode = let code = (import ./vscode.nix { inherit pkgs; });
  in code // { enable = supported code.package; };

  # FIREFOX
  programs.firefox = let pkg = pkgs.firefox-beta;
  in {
    enable = supported pkg;
    package = pkg;
  };

  # GIT
  programs.git = {
    enable = supported pkgs.git;
    userName = "MadMcCrow";
    userEmail = "noe.perard+git@gmail.com";
    lfs.enable = true;
    extraConfig = {
      help.autocorrect = 10;
      color.ui = "auto";
      core.whitespace = "trailing-space,space-before-tab";
      apply.whitespace = "fix";
    };
  };

  # github cli tool
  programs.gh = {
    enable = supported pkgs.gh;
    enableGitCredentialHelper = true;
    settings.git_protocol = "https";
    extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
  };

  programs.git-credential-oauth.enable = true;

  # ZSH :
  programs.zsh = {
    enable = supported pkgs.zsh;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    autocd = true;
    history = {
      size = 100;
      ignoreDups = true;
      ignoreSpace = true;
      extended = false;
      share = true;
    };
  };
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bash And Zsh shell history suggest box
  programs.hstr.enable = true; # only in 23.05

  programs.powerline-go = {
    enable = supported pkgs.powerline-go;
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
    #historyFile = ".bash"
  };

  # exa is ls but improved
  programs.exa = {
    enable = supported pkgs.exa;
    enableAliases = true;
    git = true;
    extraOptions = [ "--group-directories-first" "--header" ];
  };

  # environment switcher
  programs.direnv = {
    enable = supported pkgs.direnv;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
