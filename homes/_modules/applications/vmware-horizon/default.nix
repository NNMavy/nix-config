{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.applications.vmware-horizon;
in {
  options.modules.applications.vmware-horizon = {
    enable = mkEnableOption "vmware-horizon";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        vmware-horizon-client
      ];
  };
}