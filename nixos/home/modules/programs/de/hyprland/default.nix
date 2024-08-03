{ lib
, pkgs
, osConfig
, config
, inputs
, ...
}:
let

  opacity = "0.95";
  super = "SUPER";
in
{
  imports = [
    ./waybar
    ./hypridle
    ./hyprlock
    ./dunst
  ];

  config = lib.mkIf osConfig.mySystem.de.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        # hidpi = true;
      };

      settings = {

        env = [
          "BROWSER,firefox"
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORMTHEME, qt5ct"
          "QT_STYLE_OVERRIDE, kvantum"
          "QT_QPA_PLATFORM, wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, wayland"
          "MOZ_ENABLE_WAYLAND, 1"
        ];

        exec-once = [
          "polkit-agent-helper-1"
          "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
          "${pkgs.kwallet-pam}/libexec/pam_kwallet_init"
          "kwalletd5"
          "systemctl --user import-environment"
          "hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd --all"
          "wl-clip-persist --clipboard both"
          "hypridle"
          "nm-applet &"
          "hyprctl setcursor Catppuccin-Macchiato-Dark-Cursors 22 &"
          "poweralertd &"
          "waybar &"
          "wl-paste --watch cliphist store &"
          "iio-hyprland eDP-1"
        ];

        input = {
          kb_layout = "us";
          numlock_by_default = true;
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
          };
        };

        general = {
          layout = "dwindle";
          gaps_in = 0;
          gaps_out = 0;
          border_size = 2;
          "col.active_border" = "rgb(cba6f7) rgb(94e2d5) 45deg";
          "col.inactive_border" = "0x00000000";
          border_part_of_window = false;
          no_border_on_floating = false;
        };

        misc = {
          disable_autoreload = true;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          enable_swallow = true;
          focus_on_activate = true;
        };

        dwindle = {
          no_gaps_when_only = true;
          force_split = 0;
          special_scale_factor = 1.0;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
          pseudotile = "yes";
          preserve_split = "yes";
        };

        master = {
          # new_is_master = true;
          special_scale_factor = 1;
          no_gaps_when_only = false;
        };

        decoration = {
          rounding = 0;
          # active_opacity = 0.90;
          # inactive_opacity = 0.90;
          # fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 1;
            passes = 1;
            # size = 4;
            # passes = 2;
            brightness = 1;
            contrast = 1.400;
            ignore_opacity = true;
            noise = 0;
            new_optimizations = true;
            xray = true;
          };

          drop_shadow = true;

          shadow_ignore_window = true;
          shadow_offset = "0 2";
          shadow_range = 20;
          shadow_render_power = 3;
          "col.shadow" = "rgba(00000055)";
        };

        animations = {
          enabled = true;

          bezier = [
            "fluent_decel, 0, 0.2, 0.4, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutCubic, 0.33, 1, 0.68, 1"
            "easeinoutsine, 0.37, 0, 0.63, 1"
          ];

          animation = [
            # Windows
            "windowsIn, 1, 3, easeOutCubic, popin 30%" # window open
            "windowsOut, 1, 3, fluent_decel, popin 70%" # window close.
            "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

            # Fade
            "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
            "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
            "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
            "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
            "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
            "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
            "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
            "workspaces, 1, 4, easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
          ];
        };

        bind = [
          # show keybinds list
          "${super}, F1, exec, show-keybinds"

          # keybinds
          "${super}, Q, killactive,"
          "${super}, Return, exec, kitty"
          "${super}, F, fullscreen"
          "${super}, R, exec, rofi -show drun"
          "${super}, L, exec, hyprlock; 1password --lock"
          "${super}_SHIFT, S, exec, fish -c screenshot_to_clipboard"
          "CONTROL_SHIFT, space, exec, 1password --quick-access"

          # switch focus
          "${super}, left, movefocus, l"
          "${super}, right, movefocus, r"
          "${super}, up, movefocus, u"
          "${super}, down, movefocus, d"

          # switch workspace
          "${super}, 1, workspace, 1"
          "${super}, 2, workspace, 2"
          "${super}, 3, workspace, 3"
          "${super}, 4, workspace, 4"
          "${super}, 5, workspace, 5"
          "${super}, 6, workspace, 6"
          "${super}, 7, workspace, 7"
          "${super}, 8, workspace, 8"
          "${super}, 9, workspace, 9"
          "${super}, 0, workspace, 10"

          "${super}, b, togglespecialworkspace, browser"
          "${super}, p, togglespecialworkspace, onepass"

          # same as above, but switch to the workspace
          "${super} SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
          "${super} SHIFT, 2, movetoworkspacesilent, 2"
          "${super} SHIFT, 3, movetoworkspacesilent, 3"
          "${super} SHIFT, 4, movetoworkspacesilent, 4"
          "${super} SHIFT, 5, movetoworkspacesilent, 5"
          "${super} SHIFT, 6, movetoworkspacesilent, 6"
          "${super} SHIFT, 7, movetoworkspacesilent, 7"
          "${super} SHIFT, 8, movetoworkspacesilent, 8"
          "${super} SHIFT, 9, movetoworkspacesilent, 9"
          "${super} SHIFT, 0, movetoworkspacesilent, 10"
          "${super} CTRL, c, movetoworkspace, empty"

          "${super} SHIFT, b, movetoworkspace, special:browser"
          "${super} SHIFT, p, movetoworkspace, special:onepass"
        ];

        # mouse binding
        bindm = [
          "${super}, mouse:272, movewindow"
          "${super}, mouse:273, resizewindow"
        ];

        # windowrule
        windowrule = [
          "float,imv"
          "center,imv"
          "size 1200 725,imv"
          "float,mpv"
          "center,mpv"
          "tile,Aseprite"
          "size 1200 725,mpv"
          "float,title:^(float_kitty)$"
          "center,title:^(float_kitty)$"
          "size 950 600,title:^(float_kitty)$"
          "float,audacious"
          "workspace 8 silent, audacious"
          "pin,wofi"
          "float,wofi"
          "noborder,wofi"
          "tile, neovide"
          "idleinhibit focus,mpv"
          "float,udiskie"
          "float,title:^(Transmission)$"
          "float,title:^(Volume Control)$"
          "float,title:^(Firefox — Sharing Indicator)$"
          "move 0 0,title:^(Firefox — Sharing Indicator)$"
          "size 700 450,title:^(Volume Control)$"
          "move 40 55%,title:^(Volume Control)$"
        ];

        # windowrulev2
        windowrulev2 = [
          "float, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(.*imv.*)$"
          "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
          "opacity 1.0 override 1.0 override, class:(Aseprite)"
          "opacity 1.0 override 1.0 override, class:(Unity)"
          "idleinhibit focus, class:^(mpv)$"
          "idleinhibit fullscreen, class:^(firefox)$"
          "float,class:^(pavucontrol)$"
          "float,class:^(SoundWireServer)$"
          "float,class:^(.sameboy-wrapped)$"
          "float,class:^(file_progress)$"
          "float,class:^(confirm)$"
          "float,class:^(dialog)$"
          "float,class:^(download)$"
          "float,class:^(notification)$"
          "float,class:^(error)$"
          "float,class:^(confirmreset)$"
          "float,title:^(Open File)$"
          "float,title:^(branchdialog)$"
          "float,title:^(Confirm to replace files)$"
          "float,title:^(File Operation Progress)$"
          # kwallet
          "center,class:^(org.kde.kwalletd5)$"
          "dimaround,class:^(org.kde.kwalletd5)$"
          # polkit
          "float, class:^org.kde.polkit-kde-authentication-agent-1$"
          "center 1, class:^org.kde.polkit-kde-authentication-agent-1$"
          "size 560 360, class:^org.kde.polkit-kde-authentication-agent-1$"
          "dimaround, class:^org.kde.polkit-kde-authentication-agent-1$"
        ];

        monitor = [
          "eDP-1,2256x1504@60.00,0x0,1.566667"
        ];

      };

      extraConfig = "
        xwayland {
          force_zero_scaling = true
        }
      ";

      # plugins = [
      #   inputs.hyprland-hyprspace.packages.${pkgs.system}.Hyprspace
      # ];
    };
  };
}
