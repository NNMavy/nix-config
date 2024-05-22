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

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    networking.hostName = "peppernuts";

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/2c701071-7628-4dd3-a537-33f273f94f1c";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/0043-49AE";
        fsType = "vfat";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/57122c7d-8c27-4f00-a142-7b4af6ad6ec0"; }];

  };
}
