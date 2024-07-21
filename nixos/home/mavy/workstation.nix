{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
    inputs.catppuccin.homeManagerModules.catppuccin
  ];


  # Set theme for home-manager
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
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

          peppernuts = {
            hostname = "peppernuts";
            port = 22;
          };
        };
      };
    };

    shell = {

      starship.enable = true;
      fish.enable = true;
      utilities.enable = true;
      wezterm.enable = true;

      git = {
        enable = true;
        username = "Rene Koens";
        email = "mavy@ninjanerd.eu";
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
        steam
        spotify
        orca-slicer
        yubioath-flutter
        yubikey-manager-qt
        flameshot
        vlc

        # cli
        bat
        dbus
        direnv
        git
        nix-index
        python3
        fzf
        ripgrep

        brightnessctl



      ];

  };
}
