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
      {
        device = "/dev/disk/by-uuid/ea7fb7ea-32a5-440c-b205-ab3536ea4d55";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/0CB6-C964";
        fsType = "vfat";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/d8135131-adfe-4fc2-b51e-5b8cfacb0670"; }];

  };
}
