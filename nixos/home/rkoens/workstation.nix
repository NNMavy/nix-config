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
          optimus = {
            hostname = "optimus";
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
        email = "rene.koens@jumbo.com";
      };
    };
  };

  home.file.".ssh/jumbo-key.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNcxEQPS3HMkDgPwVUTuO5cP0Nv5Ua8jV3exudERtLK
  '';

  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Jumbo"
  '';

  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        slack
        spotify
        yubioath-flutter
        yubikey-manager-qt
        flameshot
        vlc
        teams-for-linux

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

        # Custom
        git-crypt
        dbeaver-bin
        mongodb-compass
        openconnect
        openfortivpn
        vpn-slice
        python311Packages.keyring
      ];

  };
}
