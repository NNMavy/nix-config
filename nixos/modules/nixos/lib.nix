{ lib, config, pkgs, ... }:
with lib;
{

  # container builder
  lib.mySystem.mkContainer = options: (
    let
      # nix doesnt have an exhausive list of options for oci
      # so here i try to get a robust list of security options for containers
      # because everyone needs more tinfoild hat right?  RIGHT?

      containerExtraOptions = lib.optionals (lib.attrsets.attrByPath [ "caps" "privileged" ] false options) [ "--privileged" ]
        ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "readOnly" ] false options) [ "--read-only" ]
        ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "tmpfs" ] false options) (map (folders: "--tmpfs=${folders}") options.caps.tmpfsFolders)
        ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "noNewPrivileges" ] false options) [ "--security-opt=no-new-privileges" ]
        ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "dropAll" ] false options) [ "--cap-drop=ALL" ];

    in
    {
      ${options.app} = {
        image = "${options.image}";
        user = "${options.user}:${options.group}";
        environment = {
          TZ = config.time.timeZone;
        } // lib.attrsets.attrByPath [ "env" ] { } options;
        dependsOn = lib.attrsets.attrByPath [ "dependsOn" ] [ ] options;
        entrypoint = lib.attrsets.attrByPath [ "entrypoint" ] null options;
        cmd = lib.attrsets.attrByPath [ "cmd" ] [ ] options;
        environmentFiles = lib.attrsets.attrByPath [ "envFiles" ] [ ] options;
        volumes = [ "/etc/localtime:/etc/localtime:ro" ]
          ++ lib.attrsets.attrByPath [ "volumes" ] [ ] options;
        ports = lib.attrsets.attrByPath [ "ports" ] [ ] options;
        extraOptions = containerExtraOptions;
      };
    }
  );


  # build a restic restore set for both local and remote
  lib.mySystem.mkRestic = options: (
    let
      excludePath = if builtins.hasAttr "excludePath" options then options.excludePath else [ ];
      timerConfig = {
        OnCalendar = "02:05";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
      pruneOpts = [
        "--keep-daily 2"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
      initialize = true;
      backupPrepareCommand = ''
        # remove stale locks - this avoids some occasional annoyance
        #
        ${pkgs.restic}/bin/restic unlock --remove-all || true
      '';

    in
    {
      # local backup
      "${options.app}-local" = mkIf config.mySystem.system.resticBackup.local.enable {
        inherit pruneOpts timerConfig initialize backupPrepareCommand;
        # Move the path to the zfs snapshot path
        paths = map (x: "${config.mySystem.system.resticBackup.mountPath}/${x}") options.paths;
        passwordFile = config.sops.secrets."services/restic/password".path;
        exclude = excludePath;
        repository = "${config.mySystem.system.resticBackup.local.location}/${options.appFolder}";
        # inherit (options) user;
      };

      # remote backup
      "${options.app}-remote" = mkIf config.mySystem.system.resticBackup.remote.enable {
        inherit pruneOpts timerConfig initialize backupPrepareCommand;
        # Move the path to the zfs snapshot path
        paths = map (x: "${config.mySystem.system.resticBackup.mountPath}/${x}") options.paths;
        environmentFile = config.sops.secrets."services/restic/env".path;
        passwordFile = config.sops.secrets."services/restic/password".path;
        repository = "${config.mySystem.system.resticBackup.remote.location}/${options.appFolder}";
        exclude = excludePath;
        # inherit (options) user;
      };

    }
  );

}
