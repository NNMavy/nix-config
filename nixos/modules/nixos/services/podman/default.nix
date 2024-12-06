{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.services.podman;
in
{
  options.mySystem.services.podman.enable = mkEnableOption "Podman";

  config = mkIf cfg.enable
    {
      virtualisation.podman = {
        enable = true;

        dockerCompat = true;
        extraPackages = [ pkgs.zfs ];

        # regular cleanup
        autoPrune.enable = true;
        autoPrune.dates = "weekly";


        # and add dns
        defaultNetwork.settings = {
          dns_enabled = true;
          ipv6_enabled = true;
          subnets = [
            { gateway = "10.88.0.1"; subnet = "10.88.0.0/16"; }
            { gateway = "fd00::1:8:1"; subnet = "fd00::1:8:0/112"; }
          ];
        };
      };
      virtualisation.oci-containers = {
        backend = "podman";
      };

      environment.systemPackages = with pkgs; [
        podman-tui # status of containers in the terminal
      ];

      networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];

      # extra user for containers
      users = {
        users.kah = {
          uid = 568;
          group = "kah";
        };
        groups.kah = { };
        users.mavy.extraGroups = [ "kah" ];
      };
    };

}
