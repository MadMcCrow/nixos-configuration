# perard.nix
# 	my User
{ pkgs, ... }:
let
id_rsa_pub_AF  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeBZ5tJd72LDKeV/icxHOcprb1seVCMbaLIC9VNntZQP9htsZ65UeuqHmxIfGcWDnl6kQlwWCJhsrJ6QHaFwxGc5V6ljdmFHLztVxemGfCAUzEg6tGKWh4hfCUQuNNKy9B8S0J6ceTStvvJiZ+3BgQM1QgrM8IwLNgiHXIZZG7SF1cMygl9csKxttirLDwjFZiqsZx6bX+fDWCKKmO4CSeCaSQC9BjB70PnTOHUYSVVsLUiH/GGnZOPb6kmT+E+AVuzFXWfjfPLlVEaIYW628ueEJR+YGJ0hIgdVbgSXW2TJcOUs6JDRAXcCemKzNZBgd+5nuCGqU1KzLVeJ+7KkLgJpWP6m4sQjxTuzGUGp3a540v4PkiqCEAzQXrb2NzgRjI6AW9whwS3zByrNh1K0EPeUeej9XtC6BvCi6vdXo1ByclGBD1MU612TAfgkSXfAXkSbTOEqVceRMLMZui7TLToidEUuYJJ4e+kFID6nrcuGjNIPJUxIVobnh0SZWju68= perard@nixAF";
id_rsa_pub_NUC = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjNFNjeTlr1M7itjddMfq1KeRF4EM4E5Tt0sANROptNdNRdbDvlXs11hG90JYZAaQNHPfj51Xq+jwkTP30nrvis2nsfPlJiflxqCTSzULzULT8YhFzQSlVZsH2o/OKTkosUm+PxDEd+E/Jvl3IQUIsDTL3i5GAlo7+/QZbQu2/b9xTlFhkXuQ/UEtoxQWEMT0Tc5+T92DxY+c4Hjqsex9liDNih4rayDFHcWgstqmpmSqiI6S6hw0UNZMCjV7ySAjHV2cfsWK9lDAsUANjZbFijE4pXaedLJA7IibofqEdM6ANKdqIKQRaExHjsgVBxQISLAkWbqPqgR6vImDv+QaJjTgJ67urKaPnkegs34e82MFvCt8MCi11Sayzxgvg2vkF7lMauvZYc0lBa6+o39cXmgFMjvPBUPSlSbq0PZKGxW3TK0QkFhcqGUWGS90j0zWkeU+u11XVCecLd3XlT44naHdkgvCzkAJabO0mREQeskyGxEZ5mlXTHT1I/NqTPec= perard@nixNUC";
in
{
  # nixos config
  users.users.perard = {
    uid = 1000;
    description = "Noé Perard-Gayot";
    group = "users";
    extraGroups = [ "wheel" "steam" "flatpak" "networkmanager" ];
    initialHashedPassword =
      "$6$7aX/uB.Zx8T.2UVO$RWDwkP1eVwwmz3n5lCAH3Nb7k/Q6wYZh05V8xai.NMtq1g3jjVNLvG8n.4DlOtR/vlPCjGXNSHTZSlB2sO7xW.";
    isNormalUser = true;

    openssh.authorizedKeys.keys = [id_rsa_pub_AF id_rsa_pub_NUC];

  };
    # home manager configuration
    home-manager.users.perard = import ./home.nix;
}
