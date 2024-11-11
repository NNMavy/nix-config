{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.gps;
in {

  config = mkIf cfg.enable {
    hardware.raspberry-pi."4".i2c1.enable = true;
    hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

    boot.kernelModules = [
      "rtc-rv3028"
    ];

    environment.systemPackages = with pkgs; [
      i2c-tools
    ];

    systemd.services.add-i2c-rtc = {
      description = "";
      wantedBy = [ "time-sync.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        # Inform the kernel about the (rv3028) i2c RTC
        echo "rv3028" "0x52" > "/sys/class/i2c-adapter/i2c-1/new_device"
      '';
    };
  };
}
