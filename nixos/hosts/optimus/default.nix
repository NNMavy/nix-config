{ config
, lib
, pkgs
, ...
}: {
  config = {

    mySystem = {
      services.openssh.enable = true;
      services.docker.enable = true;
      security.wheelNeedsSudoPassword = true;
    };

    boot = {
      initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      binfmt.emulatedSystems = [ "aarch64-linux" ];
    };

    networking.hostName = "optimus";

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/a35a06e4-ba11-4a71-a9eb-675a567a760f";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/9519-6DC7";
        fsType = "vfat";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/a85df575-7eb8-4aa5-9196-03f186cc55b6"; }];

  };
}
