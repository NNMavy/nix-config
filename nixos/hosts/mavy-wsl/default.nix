# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config
, lib
, pkgs
, ...
}: {


  config = {
    mySystem = {
      services.openssh.enable = true;
      security.wheelNeedsSudoPassword = false;
    };

    boot.initrd.availableKernelModules = ["virtio_pci"];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    networking.hostName = "mavy-wsl"; # Define your hostname.

    fileSystems."/mnt/wsl" = {
      device = "none";
      fsType = "tmpfs";
    };

    fileSystems."/usr/lib/wsl/drivers" = {
      device = "none";
      fsType = "9p";
    };

    fileSystems."/lib/modules" = {
      device = "none";
      fsType = "tmpfs";
    };

    fileSystems."/lib/modules/5.15.146.1-microsoft-standard-WSL2" = {
      device = "none";
      fsType = "overlay";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/19e61ca8-cb9c-4d0e-9c78-ff457fe4c843";
      fsType = "ext4";
    };

    fileSystems."/mnt/wslg" = {
      device = "none";
      fsType = "tmpfs";
    };

    fileSystems."/mnt/wslg/distro" = {
      device = "none";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/usr/lib/wsl/lib" = {
      device = "none";
      fsType = "overlay";
    };

    fileSystems."/mnt/wslg/doc" = {
      device = "none";
      fsType = "overlay";
    };

    fileSystems."/mnt/wslg/.X11-unix" = {
      device = "/mnt/wslg/.X11-unix";
      fsType = "none";
      options = ["bind"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/5b8c0e08-97d7-45c4-a229-87ed303a87d2";}
    ];

    };


}
