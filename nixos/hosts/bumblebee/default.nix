{ config
, lib
, pkgs
, ...
}: {
  config = {

    mySystem = {
      purpose = "Homelab";
      persistentFolder = "/persist";
      system = {
        impermanence.enable = true;
        motd.networkInterfaces = [ "enp1s0" ];
        resticBackup.remote.enable = true;
      };

      services = {
        # Enable core services
        openssh.enable = true;
        podman.enable = true;

        # Enable Ingress
        nginx.enable = true;

        # Enable hosted services
        backrest.enable = true;
        gatus.enable = true;
      };

      security.acme.enable = true;
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    networking.hostName = "bumblebee"; # Define your hostname.
    networking.hostId = "bce6d044";
    networking.useDHCP = lib.mkDefault true;

    fileSystems."/" =
      {
        device = "rpool/local/root";
        fsType = "zfs";
      };

    fileSystems."/nix" =
      {
        device = "rpool/local/nix";
        fsType = "zfs";
      };

    fileSystems."/persist" =
      {
        device = "rpool/safe/persist";
        fsType = "zfs";
        neededForBoot = true; # for impermanence
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/E6EC-784B";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/493a7dc4-c85f-4719-8100-756640d5a73a"; }];

  };
}
