# Here we configure some basic nixos features
{ pkgs, config, lib, ... }: {

  # Packages
  environment.systemPackages = with pkgs; [ nixfmt zsh exa nano wget openssl ];

  # enable zsh for all
  programs.zsh = {
    enable = true;
    # settings
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;

    # useful aliases
    shellAliases = {
      ls = "exa";
      update = "sudo nixos-rebuild switch";
      clean = "sudo nix-collect-garbage -d";
    };

    plugins = [
      # required to get zsh working in nix-shell
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };

  # make users default to zsh
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # disable sudo "lecture"
  security.sudo.extraConfig = "Defaults        lecture = never";

}
