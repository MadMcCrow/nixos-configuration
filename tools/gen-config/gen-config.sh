#!/bin/env sh
# generate the hardware configuration
# this is only intended for debugging purposes
echo "detect config and generate hardware-config";
sudo nixos-generate-config --no-filesystems --show-hardware-config | tee ./hardware-configuration.nix