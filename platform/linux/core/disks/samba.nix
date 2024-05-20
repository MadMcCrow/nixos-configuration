# disks/samba.nix
# settings to detect and mount samba shares
{ ... }: {
  services.samba-wsdd.workgroup = "WORKGROUP";
}
