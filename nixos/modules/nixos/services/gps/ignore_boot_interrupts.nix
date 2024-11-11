{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.mySystem.services.gps;

  ubootOverrides = {
    extraConfig = ''
      CONFIG_BOARD_EARLY_INIT_F=y
      CONFIG_BOOTDELAY=-2
      CONFIG_DISABLE_CONSOLE=y
      CONFIG_SILENT_CONSOLE=y
      CONFIG_SYS_DEVICE_NULLDEV=y
    '';
    extraPatches = [./u-boot-no-uart.patch];
  };

  configTxt = pkgs.writeText "config.txt" ''
    [pi3]
    kernel=u-boot-rpi3.bin

    [pi4]
    kernel=u-boot-rpi4.bin
    enable_gic=1
    armstub=armstub8-gic.bin

    # Otherwise the resolution will be weird in most cases, compared to
    # what the pi3 firmware does by default.
    disable_overscan=1

    # Supported in newer board revisions
    arm_boost=1

    [cm4]
    # Enable host mode on the 2711 built-in XHCI USB controller.
    # This line should be removed if the legacy DWC2 controller is required
    # (e.g. for USB device mode) or if USB support is not required.
    otg_mode=1

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';

  firmware = pkgs.runCommandLocal "firmware" {} ''
    mkdir $out
    ln -s ${configTxt} $out/config.txt
    ln -s ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/
    ln -s ${pkgs.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,fixup*.dat,start*.elf,bcm2711-*.dtb} $out/
    ln -s ${pkgs.ubootRaspberryPi3_64bit.override ubootOverrides}/u-boot.bin $out/u-boot-rpi3.bin
    ln -s ${pkgs.ubootRaspberryPi4_64bit.override ubootOverrides}/u-boot.bin $out/u-boot-rpi4.bin
  '';
in {
  config = mkIf cfg.ignore_boot_interrupts {
    systemd.services.ignore_boot_interrupts = {
      enable = true;
      wantedBy = [ "multi-user.target" "sysinit-reactivation.target" "sysinit.target" "basic.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        #!${pkgs.bash}/bin/bash
        #
        # Many GPS devices will produce data on the serial port before they're
        # initialized, confusing the u-boot and the bootloader into thinking
        # the user pressed a button to interrupt autoboot. Because we'd like
        # our device to boot without interaction, we force the bootloader to
        # not prompt the user. Because we override a generated config file, we
        # take care to "fix" this everytime this file gets overwritten.
        #
        # Ideally we would fix this properly, so we can rely on the bootloader
        # for fault-recovery.
        ${pkgs.gnugrep}/bin/grep -q '^PROMPT' /boot/extlinux/extlinux.conf ||
          ${pkgs.gnused}/bin/sed -i 's-^TIMEOUT \([0-9-]\+\)-TIMEOUT \1\nPROMPT 0\n-' /boot/extlinux/extlinux.conf
      '';
    };

    systemd.timers.ignore_boot_interrupts = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "3h";
        Unit = "ignore_boot_interrupts.service";
      };
    };

    boot.loader.timeout = lib.mkForce 0;

    system.activationScripts.updateFirmwarePartition.text = ''
      ${pkgs.rsync}/bin/rsync \
        --recursive --copy-links --times --checksum --delete \
        ${firmware}/ /boot/firmware/
    '';
  };
}
