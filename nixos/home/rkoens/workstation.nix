{ lib, pkgs, self, config, inputs, ... }:
with config;
{
  imports = [
    ./global.nix
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  # TODO: Make op stuff conditional and honestly cleanup this entire mess.

  # Set theme for home-manager
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "teal";
  };

  programs = {
    kitty = {
      enable = true;
      catppuccin = {
        enable = true;
        inherit (config.catppuccin) flavor;
      };
    };

    ssh.extraConfig = ''
      IdentityAgent "~/.1password/agent.sock"
    '';
    git.extraConfig = {
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "~/.ssh/allowed_signers";
          program = "${pkgs._1password-gui}/bin/op-ssh-sign";
        };
      };
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
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNcxEQPS3HMkDgPwVUTuO5cP0Nv5Ua8jV3exudERtLK";
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

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        slack
        spotify
        yubioath-flutter
        yubikey-manager-qt
        vlc
        teams-for-linux
        obsidian

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
