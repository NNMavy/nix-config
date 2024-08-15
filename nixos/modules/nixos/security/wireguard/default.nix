{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.security.wireguard;
  app = "wireguard";
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
  user = app;
  group = app;

in
{
  options.mySystem.security.wireguard.enable = mkEnableOption "wireguard";

  config = mkIf cfg.enable {
    sops.secrets = {
      "security/wireguard/privatekey" = {
        sopsFile = ./secrets.sops.yaml;
        owner = "systemd-network";
        group = "systemd-network";
      };
    };

    environment = {
      persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
        directories = [ "/var/lib/wireguard" ];
      };
      systemPackages = [
        pkgs.wireguard-tools
      ];
    };

    systemd.network = {
      enable = true;
      netdevs = {
        "10-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1300";
          };
          # See also man systemd.netdev (also contains info on the permissions of the key files)
          wireguardConfig = {
            # Don't use a file from the Nix store as these are world readable. Must be readable by the systemd.network user
            PrivateKeyFile = config.sops.secrets."security/wireguard/privatekey".path;
            ListenPort = 54640;
          };

          wireguardPeers = [{
            wireguardPeerConfig = {
              PublicKey = "VP3gZcuL7CCdna/EuJ6vlemdsPOpw2Dckn3bSrdrmjw=";
              AllowedIPs = [
                "172.16.0.0/12"
                "172.16.99.8/32"
                "172.16.99.254/32"
              ];
              Endpoint = "vpn.nnhome.eu:51800";
            };
          }];
        };
      };
      networks.wg0 = {
        # See also man systemd.network
        matchConfig.Name = "wg0";
        # IP addresses the client interface will have
        address = [
          "172.16.99.8/24"
        ];
        DHCP = "no";
        dns = ["172.16.20.11" "172.16.20.12"];
        ntp = ["172.16.20.11"];
        networkConfig = {
          IPv6AcceptRA = false;
        };
        routes = [{
          routeConfig = {
            Gateway = "172.16.99.254";
            GatewayOnLink = true;
            Destination = "172.16.0.0/12";
          };
        }];
      };
    };
  };
}
