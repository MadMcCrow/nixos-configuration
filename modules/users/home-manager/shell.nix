# home-manager/zsh.nix
#   a modern shell
{ pkgs, useZsh ? true, omz ? true, p10k ? true, useDirenv ? true, useExa ? true
, debug ? false }:
let
  lib = pkgs.lib;
  mkCondStr = b: v: if b then v else "";
  # source PowerLevel10k into my zsh config for a cool theme
  parseP10k = ''
    [[ ! -f ~/.p10k/.p10k.zsh ]] || source ~/.p10k/.p10k.zsh
                      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
  '';
in {
  packages = if useZsh then [ oh-my-zsh zsh-powerlevel10k exa ] else [ ];

  program = {
    zsh = {
      enable = useZsh;
      initExtra = mkCondStr debug ''
        zprof
      '' + (mkCondStr p10k parseP10k);
      initExtraFirst = mkCondStr debug "zmodload zsh/zprof";

      oh-my-zsh = {
        enable = omz;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
      shellAliases = { ls = "exa"; };
      # zsh plugins
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
        }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
        }
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      # smaller history
      history = {
        size = 100;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        share = true;
      };
    };

    exa = {
      enable = useExa;
      enableAliases = true;
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    direnv = {
      enable = useDirenv;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = useZsh;
    };
  };
}
