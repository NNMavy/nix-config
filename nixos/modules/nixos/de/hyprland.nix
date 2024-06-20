{ lib
, config
, pkgs
, ...
}:

with lib;
let
  cfg = config.mySystem.de.hyprland;
in
{
  options.mySystem.de.hyprland = {
    enable = mkEnableOption "hyprland";
    systrayicons = mkEnableOption "Enable systray icons" // { default = true; };
  };

  config = mkIf cfg.enable {

    # Ref: https://wiki.hyprland.org/Nix/

    sound.enable = true;

    # Set theme for nixos
    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "teal";
    };

    # hyprland plz
    programs = {
      dconf.enable = true;
      hyprland.enable = true;
      hyprlock.enable = true;
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };

    services = {
      printing.enable = true;
      fprintd.enable = true;

      # Sound stuff
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # lowLatency.enable = true;
      };

      # Enable Display Manager]
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
            user = "greeter";
          };
        };
      };
    };

    # Fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        nerd-font-patcher
      ];
    };

    environment.systemPackages = with pkgs; [
      greetd.tuigreet

      networkmanagerapplet

      pamixer                           # pulseaudio command line mixer
      pavucontrol                       # pulseaudio volume controle (GUI)
      playerctl                         # controller for media players

      wl-screenrec
      wl-clipboard
      wl-clip-persist
      cliphist
      xdg-utils
      wtype
      wlrctl
      rofi-wayland
      wofi
      wlogout

      wayland

      pyprland
      hyprpicker
      hyprcursor
      hyprpaper

      poweralertd
      kitty

      fish
      starship
      helix

      qutebrowser
      zathura
      mpv                               # video player
      imv                               # image viewer
      killall
    ];
  };
}
