{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
    inputs.catppuccin.homeModules.catppuccin
  ];


  # Set theme for home-manager
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
    kitty = {
      enable = true;
      inherit (config.catppuccin) flavor;
    };
  };

  programs = {
    kitty = {
      enable = true;
    };
  };

  myHome = {
    programs = {
      firefox.enable = true;
      k9s.enable = true;
      fluxcd.enable = true;
    };

    security = {
      ssh = {
        #TODO make this dynamic
        enable = true;
        matchBlocks = {
          mavy-wsl = {
            hostname = "mavy-wsl";
            port = 22;
          };
          bumblebee = {
            hostname = "bumblebee";
            port = 22;
          };
        };
      };
    };

    shell = {

      starship.enable = true;
      fish.enable = true;
      utilities.enable = true;

      git = {
        enable = true;
        username = "NNMavy";
        email = "3441334+NNMavy@users.noreply.github.com";
        signingKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ/Tn0MifZtxPMhWpPtRzjXMeHKcFAYXvGKMuhPRbRxST8e2JQZ8j/5uCDRh8jXI4EYCZGtgHemuekiAsJBUvWpDImUGqySSot6gWkDnAlyEt2GUDdWByqjI6hlIXXrxqk6SSI8WCU7NnyIJj9INBK3+2dKr6pkoz3Eoneo7qfryxI8IOPFJeTFEOt2+8FPew3PtAwDeydR29/kIjGMXlidZC2w0ILmGjkkbYpgVMTUKIRBmsTjLy4wMp7Dr7H88DhJbLVC4fwv/LNlXoUOoFkYTNj/reT1OtBPZurmIQ6/28xPDFBmFZ++yVfQMrur/F9Z70dX3hYm+IOOZIC0hxL";
      };
    };
  };



  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        discord
        spotify
        protonmail-desktop
        yubioath-flutter
        flameshot
        mqttui
        vlc

        # cli
        bat
        brightnessctl
        dbus
        direnv
        git
        nix-index
        python3
        fzf
        ripgrep

      ];

  };
}
