{ config, lib, pkgs, imports, boot, ... }:

with lib;
{

  mySystem.system.packages = with pkgs; [
    ntfs3g
  ];

  boot = {

    initrd.availableKernelModules = [ "virtio_pci" ];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [ ];

    # for managing/mounting ntfs
    supportedFilesystems = [ "ntfs" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "mavy";
    interop.includePath = false;
  };

  programs = {
    nix-ld = {
      enable = true;
      package = inputs.nix-ld-rs.packages.${pkgs.hostPlatform.system}.nix-ld-rs;
    };
  };
}
