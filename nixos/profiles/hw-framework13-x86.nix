{ config, lib, pkgs, imports, boot, ... }:

with lib;
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  mySystem.system.packages = with pkgs; [
    ntfs3g
  ];

  boot = {

    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    # for managing/mounting ntfs
    supportedFilesystems = [ "ntfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # why not ensure we can memtest workstatons easily?
      grub.memtest86.enable = true;

    };
  };

  hardware = {
    # Mis-detected by nixos-generate-config
    # https://github.com/NixOS/nixpkgs/issues/171093
    # https://wiki.archlinux.org/title/Framework_Laptop#Changing_the_brightness_of_the_monitor_does_not_work
    acpilight.enable = true;

    # Needed for desktop environments to detect/manage display brightness
    sensor.iio.enable = true;

    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.xserver.videoDrivers = [ "intel" ];
}
