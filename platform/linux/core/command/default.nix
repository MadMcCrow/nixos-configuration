# linux/core/command.nix
#   command line
{ ... }: {
  imports = [ ./fonts.nix ./locale.nix ./shell.nix ./ssh.nix ];
}
