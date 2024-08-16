{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.system.systemd.telegram-alerts;
in
{
  options.mySystem.system.systemd.telegram-alerts.enable = mkEnableOption "Telegram alers for systemd failures" // { default = true; };
  options.systemd.services = mkOption {
    type = with types; attrsOf (
      submodule {
        config.onFailure = [ "notify-telegram@%n.service" ];
      }
    );
  };

  config = {
    # Warn if backups are disable and machine isnt a dev box
    warnings = [
      (mkIf (!cfg.enable && config.mySystem.purpose != "Development") "WARNING: Telegram SystemD notifications are disabled!")
    ];

    systemd.services."notify-telegram@" = mkIf cfg.enable {
      enable = true;
      onFailure = lib.mkForce [ ]; # cant refer to itself on failure
      description = "Notify on failed unit %i";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.secrets."services/telegram/env".path;
      };

      # Script calls pushover with some deets.
      # Here im using the systemd specifier %i passed into the script,
      # which I can reference with bash $1.
      scriptArgs = "%i %H";
      script = ''
        ${pkgs.curl}/bin/curl --fail -s -X POST -o /dev/null \
          --form-string "text=Unit failure: '$1' on $2" \
          --form-string "chat_id=$TELEGRAM_ID" \
          https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage 2&>1

      '';
    };

  };
}
