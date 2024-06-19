{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstation or a headless server.

with config;
{

  mySystem = {

    de.hyprland.enable = true;
    devops.talos.enable = true;
    editor.vscodium.enable = true;

    security.one-password.enable = true;

    shell.fish.enable = true;

    system.resticBackup.local.enable = false;
    system.resticBackup.remote.enable = false;
  };

  boot = {
    plymouth.enable = true;
  };

  nix.settings = {
    # Avoid disk full issues
    max-free = lib.mkDefault (1000 * 1000 * 1000);
    min-free = lib.mkDefault (128 * 1000 * 1000);
  };

  # set xserver videodrivers if used
  services.xserver.enable = true;

  services = {
    fwupd.enable = config.boot.loader.systemd-boot.enable;
    thermald.enable = true;
    smartd.enable = true;

    # Yubikey requirements
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;

    # Convenient services
    printing.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    sensor.hddtemp = {
      enable = true;
      drives = [ "/dev/disk/by-id/*" ];
    };
  };

  environment.systemPackages = with pkgs; [
    # Sensors etc
    lm_sensors
    cpufrequtils
    cpupower-gui

    # Base commands
    jq
    yq-go
    btop
    vim
    git
    dnsutils
    dig
    nix
    age
    gnupg
    sops
    pre-commit
    qrencode

    # nix dev
    dnscontrol # for updating internal DNS servers with homelab services

    # TODO Move
    nil
    nixpkgs-fmt
    statix
    nvd
    gh

    bind # for dns utils like named-checkconf
    inputs.nix-inspect.packages.${pkgs.system}.default
  ];
}
