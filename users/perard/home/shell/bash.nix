# bash settings:
{ ... }:
# bash is used in nix-shell
# enable powerline-go in bash
{
  programs.bash = {

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
}
