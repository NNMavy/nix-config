{ config
, lib
, pkgs
, ...
}: {
  imports = [ ./disk-config.nix ];

  config = {
    mySystem = {
      purpose = "Jumphost";
      system = {
        impermanence = {
          enable = true;
        };
        motd.networkInterfaces = [ "eth0" ];
        resticBackup.remote.enable = false;
      };

      services = {
        # Enable core services
        openssh.enable = true;
        cloudflared.enable = true;
      };

      security.wireguard.enable = true;
    };

    boot = {
      initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
      initrd.kernelModules = [ "nvme" "virtio_gpu" ];
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

    networking = {
      hostName = "highjump"; # Define your hostname.
      hostId = "f63eac7f";
      useDHCP = lib.mkForce false;
    };


    networking = {
      nameservers = [ "8.8.8.8" ];
      defaultGateway = "172.31.1.1";
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
      dhcpcd.enable = false;
      usePredictableInterfaceNames = lib.mkForce false;
      interfaces = {
        eth0 = {
          ipv4.addresses = [
            { address = "65.108.48.212"; prefixLength = 32; }
          ];
          ipv6.addresses = [
            { address = "2a01:4f9:c012:e7ee::1"; prefixLength = 64; }
            { address = "fe80::9400:3ff:fea0:19b0"; prefixLength = 64; }
          ];
          ipv4.routes = [{ address = "172.31.1.1"; prefixLength = 32; }];
          ipv6.routes = [{ address = "fe80::1"; prefixLength = 128; }];
        };
      };
    };

    fileSystems = {
      "/" =
        {
          device = "rpool/local/root";
          fsType = "zfs";
        };

      "/nix" =
        {
          device = "rpool/local/nix";
          fsType = "zfs";
        };

      "/persist" =
        {
          device = "rpool/safe/persist";
          fsType = "zfs";
          neededForBoot = true; # for impermanence
        };

      "/boot" =
        {
          device = "/dev/disk/by-partlabel/disk-disk1-ESP";
          fsType = "vfat";
          options = [ "fmask=0022" "dmask=0022" ];
        };
    };

    swapDevices = [ ];

  };
}
