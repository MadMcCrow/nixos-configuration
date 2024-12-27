# NIXOS :

## Secure Boot :

After normal installation, do this :
 1. make sure to have secure boot enabled in setup mode
 2. run :
    ```
    nix-shell -p sbctl --run "sudo sbctl create-keys"
    nix-shell -p sbctl --run "sudo sbctl enroll-keys --microsoft"
    nix-shell -p sbctl --run "sbctl status"
    ```
    this ensure that secure boot is enabled.
    more details [in lanzaboote] (https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)

## TPM2 unlock :

    with this config you can use luks passwordless :
    `sudo systemd-cryptenroll /dev/$DISK --tpm2-device=auto --tpm2-pcrs=0+2+7` is run after every rebuild, so you are safe !
    see [this reddit thread](https://www.reddit.com/r/NixOS/comments/xrgszw/nixos_full_disk_encryption_with_tpm_and_secure/) for details !
          

