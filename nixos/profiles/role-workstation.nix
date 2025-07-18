{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstation or a headless server.

with config;
{

  mySystem = {

    de.cosmic.enable = true;
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

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  nix.settings = {
    # Avoid disk full issues
    max-free = lib.mkDefault (1000 * 1000 * 1000);
    min-free = lib.mkDefault (128 * 1000 * 1000);
  };

  # set xserver videodrivers if used
  services.xserver.enable = false;

  services = {
    fwupd.enable = config.boot.loader.systemd-boot.enable;
    thermald.enable = true;
    smartd.enable = true;
    pulseaudio.enable = false;

    # Yubikey requirements
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;

    # Convenient services
    printing.enable = true;
    blueman.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    sensor.hddtemp = {
      enable = true;
      drives = [ "/dev/disk/by-id/*" ];
    };
    i2c.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
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
    pinentry-curses
    blueman

    # nix dev
    dnscontrol # for updating internal DNS servers with homelab services

    # TODO Move
    nil
    nixpkgs-fmt
    statix
    nvd
    nix-output-monitor
    gh
    ddcutil

    bind # for dns utils like named-checkconf
    inputs.nix-inspect.packages.${pkgs.system}.default
  ];
}
