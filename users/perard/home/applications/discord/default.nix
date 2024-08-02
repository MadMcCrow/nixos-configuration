# discord setup for nixos:
{ ... }: {
  imports = [
    #./discord.nix # non free, needs a lot of tweaks 
    ./vesktop.nix # free, fast and all
  ];
}
