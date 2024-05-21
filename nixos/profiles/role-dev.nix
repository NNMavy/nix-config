{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstation or a headless server.

with config;
{

  mySystem = {
    devops.talos.enable = true;
  };

  environment.systemPackages = with pkgs; [
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
