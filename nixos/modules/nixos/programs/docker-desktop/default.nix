{ lib
, config
, pkgs
, ...
}:
with lib; let
  cfg = config.mySystem.programs.docker-desktop;
  top = if builtins.hasAttr "wsl" config then config.wsl else null;
  dockerRoot = if builtins.hasAttr "wslConf" top then top.wslConf.automount.root else "";
  proxyPath = "${dockerRoot}/docker-desktop-user-distro";
in
{
  options.mySystem.programs.docker-desktop = {
    enable = mkEnableOption "docker-desktop";
  };

  config = mkIf cfg.enable (mkMerge [{
    wsl.docker-desktop.enable = true;

    # unit-script-docker-desktop-proxy-start
    systemd.services.docker-desktop-proxy = {
      path = [ pkgs.mount ];
      script = lib.mkForce ''
        ${proxyPath} proxy "C:\Program Files\Docker\Docker\resources" --docker-desktop-root ${dockerRoot}
      '';
      unitConfig.ConditionPathExists = proxyPath;
    };

    systemd.paths.docker-desktop-proxy = {
      inherit (top.docker-desktop) enable;
      description = "Watcher for Docker Desktop proxy integration";
      # IDEA can we shift the burden to docker-desktop-proxy.service itself?
      wantedBy = [ "multi-user.target" ];

      pathConfig = {
        PathExists = proxyPath;
      };
    };
  }]);
}
