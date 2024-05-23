{ lib
, config
, self
, pkgs
, inputs
, ...
}:
with lib;
let
  cfg = config.mySystem.devops.talos;
in
{
  options.mySystem.devops.talos.enable = mkEnableOption "talos";

  config = mkIf cfg.enable {

    # Install talos tools
    environment.systemPackages = with pkgs; [
      cilium-cli
      cloudflared
      hubble
      krew
      kubectl
      kubectl-cnpg
      kubectx
      kubernetes-helm
      kustomize_4
      minio-client
      opentofu
      talosctl
      inputs.talhelper.packages.${pkgs.system}.default
      terraform
    ];
    programs.fish = {
      shellAliases = {
        k = "kubectl";
        kn = "kubens";
        kc = "kubectx";
        tf = "terraform";
      };
    };
  };
}
