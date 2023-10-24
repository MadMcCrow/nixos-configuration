# home.nix
# home manager configuration for user
{ config, pkgs, firefox-gnome-theme, ... }:
with builtins;
with pkgs.lib;
let

  # multiplatform support
  platform = pkgs.system;
  isLinux = strings.hasSuffix "linux" platform;
  isDarwin = strings.hasSuffix "darwin" platform;

  mkCondSet = base: cond: ifTrue: ifFalse:
    mkMerge [ base (if cond then ifTrue else ifFalse) ];

  # true if this program can work
  supported = pkg: (elem platform pkg.meta.platforms) && !pkg.meta.unsupported;

  # firefox-gnome-theme
  firefox-gnome-theme = pkgs.stdenvNoCC.mkDerivation rec {
    name = "firefox-gnome-theme";
    version = "115";
    src = pkgs.fetchurl {
      url =
        "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/refs/tags/v115.tar.gz";
      sha256 =
        "c676055e1e47442a147587fa6388754b182c9df907954ff6914eaca776056b47";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv icon.svg $out
      mv user*.css $out
      mv theme $out
      mv scripts $out
      mv configuration $out
      runHook postInstall
    '';
  };

in {

  home.username = "perard";
  home.homeDirectory = "/home/perard";
  home.stateVersion = "23.11";

  # add our dconf settings
  imports = [ ./dconf.nix ];

  # packages to install to profile
  home.packages = filter (x: supported x) (with pkgs; [
    git
    gh
    eza
    powerline-go
    zsh-autosuggestions
    zsh-syntax-highlighting
    jetbrains-mono
    speechd
    python3
    #libclang
    clang-tools_16
    bitwarden
  ]);

  # enable HM
  programs.home-manager.enable = true;

  # Programs setup :
  # vscode is in another module (too many extensions)
  programs.vscode = let code = (import ./vscode.nix { inherit pkgs; });
  in code // { enable = supported code.package; };

  # FIREFOX
  programs.firefox = let package = pkgs.firefox-beta;
  in {
    enable = supported package;
    inherit package;
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
  programs.gh = mkCondSet {
    enable = supported pkgs.gh;
    settings.git_protocol = "https";
    extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
  } isLinux { gitCredentialHelper.enable = true; } {
    enableGitCredentialHelper = true;
  };

  # needs custom merge
  #programs = if isLinux then {git-credential-oauth.enable = true;} else {};

  # ZSH :
  programs.zsh = mkCondSet {
    enable = supported pkgs.zsh;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
    ];
    history = {
      size = 100;
      ignoreDups = true;
      ignoreSpace = true;
      extended = false;
      share = true;
    };
    # alias vscodium to vscode
    shellAliases = { code = "codium"; };
  } isLinux { syntaxHighlighting.enable = true; } {
    enableSyntaxHighlighting = true;
  };

  services.gpg-agent = mkIf isLinux {
    enable = true;
    enableZshIntegration = true;
  };

  # Bash And Zsh shell history suggest box
  programs.hstr.enable = true;

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

  # eza is ls but improved
  programs.eza = {
    enable = supported pkgs.eza;
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
