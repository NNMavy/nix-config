{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.gps;
in
{
  options.mySystem.services.gps = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Use a (stratum 0) GPS receiver as refclock";
    };

    gpsd_watchdog.enable = mkOption {
      default = cfg.enable;
      type = types.bool;
      description = mdDoc ''
        In some cases a GNSS device can be deactived only to return a few
        seconds later (with some modules more than others). However, by this
        time gpsd has often already removed the device and because gpsd drops
        root priviliges after initialization it is unable to re-initialize
        the device.

        The proper solution would be to fix the issue of why your GPS
        module resets (faulty cabling, faulty module, another device
        using the same GPIO pins, etc).

        See  [this gpsd issue](https://gitlab.com/gpsd/gpsd/-/issues/211) for
        more details.

        This option will enable a watchdog that will monitor chrony & gpsd
        and restart gpsd when it detects that gpsd hasn't been forwarding the
        NMEA and PPS signals for a while.
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.deviceTree = {
      enable = true;
      overlays = [
        {
          name = "rpi4-pps-gpio-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";
              fragment@0 {
                target-path = "/";
                __overlay__ {
                  pps: pps@12 {
                    compatible = "pps-gpio";
                    pinctrl-names = "default";
                    pinctrl-0 = <&pps_pins>;
                    gpios = <&gpio 18 0>;
                    status = "okay";
                  };
                };
              };

              fragment@1 {
                target = <&gpio>;
                __overlay__ {
                  pps_pins: pps_pins@12 {
                    brcm,pins =     <18>;
                    brcm,function = <0>;    // in
                    brcm,pull =     <0>;    // off
                  };
                };
              };

              __overrides__ {
                gpiopin = <&pps>,"gpios:4",
                    <&pps>,"reg:0",
                    <&pps_pins>,"brcm,pins:0",
                    <&pps_pins>,"reg:0";
                assert_falling_edge = <&pps>,"assert-falling-edge?";
                capture_clear = <&pps>,"capture-clear?";
                pull = <&pps_pins>,"brcm,pull:0";
              };
            };
          '';
        }
        {
          name = "rtc-i2c";
          dtboFile = ../../../../overlays/i2c-rtc.dtbo;

        }
        {
          name = "disable-bt";
          dtboFile = ../../../../overlays/disable-bt.dtbo;
        }
      ];
    };

    systemd.services."serial-getty@ttyS0".enable = false;

    services.gpsd = {
      enable = true;
      nowait = true;
      readonly = false;
      listenany = false;
      debugLevel = 0;
      devices = [
        "/dev/ttyS0"
        "/dev/pps0"
      ];
      extraArgs = [
        "-r"
        "-p"
        "-s"
        "115200"
      ];
    };

    environment.systemPackages = with pkgs; [
      gpsd
      pps-tools
      jq
    ];
  };

  imports = [
    ./exporter.nix
    ./i2c-rtc.nix
    ./gpsd_watchdog.nix
  ];
}
