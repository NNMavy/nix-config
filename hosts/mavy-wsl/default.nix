{
  inputs,
  pkgs,
  config,
  options,
  lib,
  ...
}: let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "mavy-wsl";
  };

  users.users.mavy = {
    uid = 1000;
    name = "mavy";
    home = "/home/mavy";
    group = "mavy";
    shell = pkgs.fish;
    packages = [pkgs.home-manager];
    openssh.authorizedKeys.keys = [(builtins.readFile ../../homes/mavy/config/ssh/ssh.pub)];
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

  system.activationScripts.postActivation.text = ''
    # Must match what is in /etc/shells
    chsh -s /run/current-system/sw/bin/fish mavy
  '';

  # Enable printing changes on nix build etc with nvd
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';

  modules = {
    services = {
      openssh.enable = false;
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
}
