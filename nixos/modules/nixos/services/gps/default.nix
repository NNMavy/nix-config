{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.gps;
in {
  options.mySystem.services.gps = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Use a (stratum 0) GPS receiver as refclock";
    };

    serial = {
      path = mkOption {
        default = "/dev/ttyS1";
        type = types.str;
        description = mdDoc "Path to the GNSS/GPS UART/serial device";
      };
      offset = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = mdDoc ''
        The known constant offset of this device (not including the PPS signal)

        After monitoring your situation for a bit you'll probably notice the
        serial-connected device as a somewhat-constant offset from the PPS
        signal, which you can configure here for extra clean output.
        '';
        example = "0.120";
      };
      refid = mkOption {
        default = "NMEA";
        type = types.str;
        description = mdDoc ''
        The NTP Reference ID (refid) for this device

        In the NTP message the server returns to the client, this is a field
        that can be used by stratum 1 servers (like us) to indicate what
        their stratum 0 clock is. There is an authoritative list of Reference
        Identifiers maintained by IANA, see
        [here](https://www.meinbergglobal.com/english/info/ntp-refid.htm) for
        an overview.

        In addition to enabling clients to tell the source of their time, the
        refid can also be used to lock a PPS reference clock to another
        clock.

        This is the refid for the UART device which we will actually not
        broadcast to clients, so it doesn't matter that much what you set
        this to. Do keep in mind restrictions apply (e.g. only ascii, max 4
        chars).
        '';
      };
    };

    pps = {
      path = mkOption {
        default = "/dev/pps0";
        type = types.str;
        description = mdDoc ''
        Path to the GNSS PPS device

        Note that some GNSS receivers will only initialize the PPS device
        after being talked to by [gpsd](https://gpsd.io/).
        '';
      };
      lock = mkOption {
        default = cfg.serial.refid;
        type = types.str;
        description = mdDoc ''
        The NTP Reference ID (refid) of another reference clock to lock the
        PPS clock to.

        Because the PPS device only tells us the (quite exact) edge of a
        second but not what second that is, we need another clock source to
        be able to actually tell the time of day.

        This option allows us to "lock" the PPS signal to another refclock,
        adding the precision of the PPS signal to the more complete but
        (presumably) less accurate other refclock.
        '';
      };
      refid = mkOption {
        default = "PPS";
        description = mdDoc ''
        The NTP Reference ID (refid) for the PPS clock.

        In the NTP response message this is a field that in the case of a
        stratum 1 server (like us) indicates what their stratum 0 clock is.
        There is an authoritative list of Reference Identifiers maintained by
        IANA, see
        [here](https://www.meinbergglobal.com/english/info/ntp-refid.htm) for
        an overview.

        If you've configured your GNSS receiver to only use a particular
        constellation, other values of interest might be *GOES*, *GPS* or
        *GAL*. The default value of *PPS* indicates a generic
        pulse-per-second refclock.
        '';
      };
    };

    ignore_boot_interrupts = mkOption {
      default = true;
      type = types.bool;
      description = mdDoc ''
        Most GNSS devices will transmit data on the serial port before being
        talked to, making u-boot and the bootloader think the user pressed a
        keyboard button to interrupt autoboot.

        Because we'd like our device to boot without interaction we force the
        bootloader to not prompt the user. Because we override a generated
        config file, we take care to "fix" this everytime this file gets
        overwritten.

        Ideally we would fix this properly, so we can rely on the bootloader
        for fault-recovery.
      '';
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

    systemd.services."serial-getty@${baseNameOf cfg.serial.path}".enable = false;

    services.gpsd = {
      enable = true;
      nowait = true;
      readonly = false;
      listenany = false;
      debugLevel = 3;
      devices = [
        cfg.serial.path
        cfg.pps.path
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
    ./i2c-rtc.nix
    ./gpsd_watchdog.nix
    ./ignore_boot_interrupts.nix
  ];
}
