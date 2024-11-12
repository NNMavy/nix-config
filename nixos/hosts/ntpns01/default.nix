# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ../modules/nixos/hardware/u-boot/ignore_boot_interrupts.nix
  ];

  mySystem.services = {

    openssh.enable = true;
    adguardhome.enable = true;

    gps = {
      enable = true;
      serial = {
        path = "/dev/ttyS0";
        offset = "0.050";
      };
    };
    chrony =  {
      enable = true;
      allowedIPv4Ranges = [
        { address = "127.0.0.1"; prefixLength = 8; }
        { address = "172.16.20.0"; prefixLength = 24; }
        { address = "172.16.30.0"; prefixLength = 24; }
      ];
      allowedIPv6Ranges = [
        { address = "fe80::"; prefixLength = 10; }
        { address = "2a02:a472:e8b3::"; prefixLength = 48; }
      ];
    };
  };

  hardware.raspberry-pi."4".i2c1.enable = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  # no mutable state I care about
  mySystem.system.resticBackup =
    {
      local.enable = false;
      remote.enable = false;
    };
  mySystem.system.autoUpgrade = {
    enable = false;
  };

  networking.hostName = "ntpns01"; # Define your hostname.
  networking.useDHCP = lib.mkDefault true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "relatime" ];
    };
  };

  swapDevices = [ ];
}
