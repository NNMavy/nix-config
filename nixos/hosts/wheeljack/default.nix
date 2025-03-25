{ config
, lib
, pkgs
, ...
}: {
  config = {

    mySystem = {
      purpose = "Github Actions";
      persistentFolder = "/persist";
      system = {
        impermanence.enable = true;
        motd.networkInterfaces = [ "eno1" ];
        resticBackup = {
          remote.enable = false;
          local.enable = false;
        };
      };

      services = {
        # Enable core services
        openssh.enable = true;
        docker.enable = true;

        # Enable hosted services
        github-runner.enable = true;
      };

      security.acme.enable = true;
    };

    boot = {
      initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "nvme" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      binfmt.emulatedSystems = [ "aarch64-linux" ];
    };

    networking = {
      hostName = "wheeljack"; # Define your hostname.
      hostId = "00b43912";
      useDHCP = lib.mkDefault true;
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
          device = "/dev/disk/by-uuid/F8D3-3CCE";
          fsType = "vfat";
          options = [ "fmask=0022" "dmask=0022" ];
        };
    };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/49a334eb-b825-4fdf-92b6-ee09aea03669"; }];

  };
}
