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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.xserver.videoDrivers = [ "intel" ];
}
