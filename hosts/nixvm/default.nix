{
  inputs,
  pkgs,
  config,
  ...
}: let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  networking = {
    hostName = "pepeprnuts";
    hostId = "decaf108";
    useDHCP = true;
    firewall.enable = false;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
    ];
  };

  users.users.mavy = {
    uid = 1000;
    name = "mavy";
    home = "/home/mavy";
    group = "mavy";
    shell = pkgs.fish;
    packages = [pkgs.home-manager];
    openssh.authorizedKeys.keys = [(builtins.readFile ../../homes/mavy/config/ssh/ssh.pub)];
    hashedPasswordFile = config.sops.secrets.mavy-password.path;
    isNormalUser = true;
    extraGroups =
      ["wheel"]
      ++ ifGroupsExist [
        "network"
        "samba-users"
      ];
  };
  users.groups.mavy = {
    gid = 1000;
  };

  sops.secrets.mavy-password = {
    sopsFile = ../../homes/mavy/hosts/peppernuts/secrets.sops.yaml;
    neededForUsers = true;
  };

  system.activationScripts.postActivation.text = ''
    # Must match what is in /etc/shells
    chsh -s /run/current-system/sw/bin/fish mavy
  '';

  modules = {
    services = {
      openssh.enable = true;
    };

    users = {
      groups = {
        homelab = {
          gid = 568;
          members = ["mavy"];
        };
      };
      additionalUsers = {
        homelab = {
          uid = 568;
          group = "homelab";
          isNormalUser = false;
        };
      };
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
