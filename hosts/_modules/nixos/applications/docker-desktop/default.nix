{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.applications.docker-desktop;
  top = config.wsl;
  dockerRoot = "${top.wslConf.automount.root}/wsl/docker-desktop";
  proxyPath = "${dockerRoot}/docker-desktop-user-distro";
in {
  options.modules.applications.docker-desktop = {
    enable = mkEnableOption "docker-desktop";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      wsl.docker-desktop.enable = true;

      # unit-script-docker-desktop-proxy-start
      systemd.services.docker-desktop-proxy = {
        path = [pkgs.mount];
        script = lib.mkForce ''
          ${proxyPath} proxy "C:\Program Files\Docker\Docker\resources" --docker-desktop-root ${dockerRoot}
        '';
        unitConfig.ConditionPathExists = proxyPath;
      };

      systemd.paths.docker-desktop-proxy = {
        inherit (top.docker-desktop) enable;
        description = "Watcher for Docker Desktop proxy integration";
        # IDEA can we shift the burden to docker-desktop-proxy.service itself?
        wantedBy = ["multi-user.target"];

        pathConfig = {
          PathExists = proxyPath;
        };
      };
    })
  ];
}
