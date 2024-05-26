{ config
, lib
, pkgs
, ...
}: {
  config = {

    mySystem = {
      services.openssh.enable = true;
      security.wheelNeedsSudoPassword = true;
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    networking.hostName = "optimus";

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/91e22c11-5d04-4a58-95eb-76e6c8951321";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/E7FC-464C";
        fsType = "vfat";
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/84efee5e-3ad6-460d-b35a-da44b34cc1b9"; }
      ];

  };
}
