{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.devops;
in {
  imports = [
    ./fluxcd
    ./k9s
  ];

  options.modules.devops = {
    enable = mkEnableOption "devops";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cilium-cli
      cloudflared
      hubble
      krew
      kubectl
      kubectl-cnpg
      kubernetes-helm
      kustomize_4
      minio-client
      opentofu
      # pulumi-bin
      talhelper
      talosctl
      terraform
    ];

    programs.fish = {
      shellAliases = {
        k = "kubectl";
        tf = "terraform";
      };
    };
  };
}
