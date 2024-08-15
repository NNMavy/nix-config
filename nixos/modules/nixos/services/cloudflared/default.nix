{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.cloudflared;
  app = "cloudflared";
  appFolder = "/var/lib/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
  user = app;
  group = app;

in
{
  options.mySystem.services.cloudflared.enable = mkEnableOption "cloudflared";

  config = mkIf cfg.enable {
    # TODO: Make this a config option for future nodes. Currently only supports jump hosts
    sops.secrets = {
      "services/ssh/ca".sopsFile = ./secrets.sops.yaml;
      "services/cloudflared/env".sopsFile = ./secrets.sops.yaml;
      "services/cloudflared/env".restartUnits = [ "${app}.service" ];
    };

    environment = {
      persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
        directories = [ "/var/lib/cloudflared" ];
      };

      systemPackages = with pkgs;
        [
          cloudflared
        ];
    };

    services.openssh.extraConfig =
      ''
      PubkeyAuthentication yes
      TrustedUserCAKeys ${config.sops.secrets."services/ssh/ca".path}
      '';

    users.users.cloudflared = {
      group = "cloudflared";
      isSystemUser = true;
    };
    users.groups.cloudflared = { };

    systemd.services.cloudflared = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        EnvironmentFile = config.sops.secrets."services/cloudflared/env".path;
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
        Restart = "always";
        User = "cloudflared";
        Group = "cloudflared";
      };
    };


  };
}
