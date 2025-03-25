{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.services.docker;
in
{
  options.mySystem.services.docker.enable = mkEnableOption "Docker";

  config = mkIf cfg.enable
    {
      virtualisation.docker = {
        enable = true;

        extraPackages = [ pkgs.zfs ];

        # regular cleanup
        autoPrune.enable = true;
        autoPrune.dates = "weekly";


        #   # and add dns
        #   defaultNetwork.settings = {
        #     dns_enabled = true;
        #     ipv6_enabled = true;
        #     subnets = [
        #       { gateway = "10.88.0.1"; subnet = "10.88.0.0/16"; }
        #       { gateway = "fd00::1:8:1"; subnet = "fd00::1:8:0/112"; }
        #     ];
        #   };
      };
      virtualisation.oci-containers = {
        backend = "docker";
      };

      environment.systemPackages = with pkgs; [
        docui # status of containers in the terminal
      ];

      #networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];

      # extra user for containers
      users = {
        users.kah = {
          uid = 568;
          group = "kah";
          extraGroups = [ "docker" ];
        };
        groups.kah = { };
        users.mavy.extraGroups = [ "kah" "docker" ];
      };
    };

}
