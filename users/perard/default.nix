# perard.nix
# 	my User
{ pkgs, ... }:
{
  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    group = "users";
    extraGroups = [ "wheel" "steam" "flatpak" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    isNormalUser = true;

    # public key 
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5St49P6e3xz3fZlmquzfiLsiTJ2wnuHsmvZTscdHB2ZmEQtoMoogkgE4lfPyRgbIFQOFqd5E+QPFS7llw24ycOZvHVckKi4FBjSKPuevOWRDkv6nmlGe616FjrGavYLjec3IPqMMVw6vY2Pgolo7Wje2bkKrOOZNg/OgE4/jP1t9GVPHR65kOajt3kzrMUaVyq7CHPEINgp5fwRCofoyWK0x+2YMu9zHJHfwi5aLhThbyuf3+z3Mn3jfpRol0r4mOyRXUgkKuj6wudxHuxsx/DlsXL+kzISyWq3jg3txkSe2CYZNjEXgP7CWiF4iyZneQMdBU06/E3VkzcEu+8/ynNjMKgFHkhqws2ewGPSqzRHPAqzlqtMCP9/ADtIRgbKEr7jUjluACpnip22sjfLvPPCzaa5qbQ54awsVYDObwJuFDmkXMFUob6omth4QsEjQcsHfmMhHK5htzTT5qinTRipzUz/SX10v87Bsy8OiyjPNV/cCmiw8WbLJ1ew1JJms= perard@nixAF"];

  };
    # home manager configuration
    home-manager.users.perard = import ./home.nix;
}
