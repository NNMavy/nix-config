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
    ./plasma.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  networking = {
    hostName = "peppernuts";
    firewall.enable = false;
    networkmanager.enable = true;
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
    description = "Rene Koens";
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
        "networkmanager"
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
    applications = {
      one-password.enable = true;
    };
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
