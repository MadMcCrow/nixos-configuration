# home.nix
# home manager configuration for user
{ config, pkgs, firefox-gnome-theme, ... }:
with builtins;
with pkgs.lib;
let

  # multiplatform support
  platform = pkgs.system;
  isLinux  = strings.hasSuffix "linux"  platform;
  isDarwin = strings.hasSuffix "darwin" platform;

  mkCondSet = base : cond : ifTrue : ifFalse :  mkMerge [base (if cond then ifTrue else ifFalse )];

  # true if this program can work
  supported = pkg: ( elem platform pkg.meta.platforms) && !pkg.meta.unsupported;

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
  home.stateVersion = "23.05";

  # add our dconf settings
  imports = [ ./dconf.nix ];

  # packages to install to profile
  home.packages = filter ( x: supported x) (with pkgs; [
    git
    gh
    exa
    powerline-go
    zsh-autosuggestions
    zsh-syntax-highlighting
    jetbrains-mono
    speechd
    python3
  ]);

  # enable HM
  programs.home-manager.enable = true;

  # Programs setup :
  # vscode is in another module (too many extensions)
  programs.vscode = let code = (import ./vscode.nix { inherit pkgs; });
  in code // { enable = supported code.package; };

  # FIREFOX
  programs.firefox =
  let 
  package = pkgs.firefox-beta;
  in {
    enable = supported package;
    inherit package;
    # GTK4 theme for firefox
    profiles.nix-user-profile = {
      userChrome = ''@import "firefox-gnome-theme/userChrome.css";'';
      userContent = ''@import "firefox-gnome-theme/userContent.css";'';
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
        "browser.theme.dark-private-windows" = false;
      };
    };
  };
  home.file.".mozilla/firefox/nix-user-profile/chrome/firefox-gnome-theme".source =
    firefox-gnome-theme;

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
  programs.gh = mkCondSet 
    {
      enable = supported pkgs.gh;
      settings.git_protocol = "https";
      extensions = with pkgs; [ gh-eco gh-cal gh-dash ];
    }
    isLinux 
    {gitCredentialHelper.enable = true;} 
    {enableGitCredentialHelper = true;};

  # needs custom merge
  #programs = if isLinux then {git-credential-oauth.enable = true;} else {};

  # ZSH :
  programs.zsh = mkCondSet {
    enable = supported pkgs.zsh;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    autocd = true;
    history = {
      size = 100;
      ignoreDups = true;
      ignoreSpace = true;
      extended = false;
      share = true;
    };
  } 
  isLinux
  {syntaxHighlighting.enable = true;}
  {enableSyntaxHighlighting = true; };

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
