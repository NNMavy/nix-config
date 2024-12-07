{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.de.cosmic;
in
{
  options.mySystem.de.cosmic = {
    enable = mkEnableOption "cosmic";
  };

  config = mkIf cfg.enable {
    services = {
      desktopManager = {
        cosmic.enable = true;
      };
      displayManager = {
        cosmic-greeter.enable = true;
      };
      gnome.gnome-keyring.enable = true;

      # Conventient services
      printing.enable = true;
      fprintd.enable = true;
    };

    # required for authentication
    services.accounts-daemon.enable = true;
    security.pam.services.cosmic-greeter = { };
    services.dbus.packages = with pkgs; [ cosmic-greeter ];
    security.pam.services.login.enableGnomeKeyring = true;

    # extra pkgs and extensions
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        COSMIC_DATA_CONTROL_ENABLED = 1;
        QT_QPA_PLATFORM = "wayland";
        GTH_THEME = "adw-gtk3-dark";
      };
      systemPackages = with pkgs; [
        cosmic-idle
        xdg-desktop-portal-cosmic
        cosmic-ext-applet-clipboard-manager
        cosmic-ext-applet-emoji-selector
        cosmic-ext-calculator
        cosmic-ext-examine
        cosmic-ext-forecast
        cosmic-ext-tasks
        cosmic-ext-tweaks
        cosmic-player
        cosmic-reader
        chronos
        quick-webapps
        stellarshot
        seahorse
        adw-gtk3
      ];
    };

    # And dconf
    programs.dconf.enable = true;

    # Fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        nerd-font-patcher
        (nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];
    };
  };
}
