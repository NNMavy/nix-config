{ config, lib, pkgs, imports, boot, ... }:

with lib;
{
  imports = [
    (inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  boot = {

    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" ];
    kernelModules = [ "virtio_gpu" ];
    kernelParams = [ "console=tty" ];
    extraModulePackages = [ ];

    loader = {
      grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        #memtest86.enable = true;
        device = "nodev";
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
