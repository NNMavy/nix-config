{ config, lib, pkgs, imports, boot, ... }:

with lib;
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    kernelParams = [
      "8250.nr_uarts=1"
      "console=tty1"
    ];

    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";

  console.enable = false;

  mySystem.system.packages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
