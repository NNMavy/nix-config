{ lib
, config
, pkgs
, ...
}:
with lib; let
  cfg = config.mySystem.security.one-password;

  op-wsl-proxy = pkgs.writeShellScriptBin "op" ''
    if [ -n "$WSL_DISTRO_NAME" ] && command -v op.exe >/dev/null; then
      exec op.exe "$@"
    fi
  '';

  # This approach is originally based on
  # https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/ but has been
  # heavily simplified on the one side and extendet to automaticall install
  # npiperelay on the other side. We'd really like to define a systemd user
  # service, but that's not posisble on WSL2 by default. (since there is no
  # systemd).
  wsl-ssh-agent = pkgs.writeShellScriptBin "wsl-ssh-agent" ''
    export SSH_AUTH_SOCK=$HOME/.1password/agent.sock
    export PATH=$PATH:/mnt/c/windows/system32
    mkdir -p $HOME/.1password

    ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
    if [[ $ALREADY_RUNNING != "0" ]]; then
      rm -f "$SSH_AUTH_SOCK"

      WINPATH="$(wslpath "$( (cd /mnt/c/; cmd.exe /c 'echo %LOCALAPPDATA%') | sed -e 's/\r//')")/nix-cache"
      if ! [ -e "$WINPATH" ]; then
        mkdir "$WINPATH"
      fi

      if ! cmp -s ${pkgs.flake.npiperelay}/bin/npiperelay.exe "$WINPATH/npiperelay.exe"; then
        cp ${pkgs.flake.npiperelay}/bin/npiperelay.exe "$WINPATH/npiperelay.exe"
      fi

      (setsid ${pkgs.socat}/bin/socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$WINPATH/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
  '';
  wslAgentScript = "source ${lib.getExe wsl-ssh-agent}";
in
{
  options.mySystem.security.one-password = {
    enable = mkEnableOption "one-password";
    wsl = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && !cfg.wsl) {
      programs = {
        _1password = {
          enable = true;
        };
        _1password-gui = {
          enable = true;
          polkitPolicyOwners = [ "mavy" ];
        };
      };

      home-manager.users.mavy.programs = {
        ssh.extraConfig = ''
          IdentityAgent "~/.1password/agent.sock"
        '';
        git.extraConfig = {
          user.signingKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ/Tn0MifZtxPMhWpPtRzjXMeHKcFAYXvGKMuhPRbRxST8e2JQZ8j/5uCDRh8jXI4EYCZGtgHemuekiAsJBUvWpDImUGqySSot6gWkDnAlyEt2GUDdWByqjI6hlIXXrxqk6SSI8WCU7NnyIJj9INBK3+2dKr6pkoz3Eoneo7qfryxI8IOPFJeTFEOt2+8FPew3PtAwDeydR29/kIjGMXlidZC2w0ILmGjkkbYpgVMTUKIRBmsTjLy4wMp7Dr7H88DhJbLVC4fwv/LNlXoUOoFkYTNj/reT1OtBPZurmIQ6/28xPDFBmFZ++yVfQMrur/F9Z70dX3hYm+IOOZIC0hxL";
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
      # Work Profile  
      home-manager.users.rkoens.programs = {
        ssh.extraConfig = ''
          IdentityAgent "~/.1password/agent.sock"
        '';
        git.extraConfig = {
          user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNcxEQPS3HMkDgPwVUTuO5cP0Nv5Ua8jV3exudERtLK";
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
    })

    (mkIf (cfg.enable && cfg.wsl) {
      home-manager.users.mavy.home.packages = [
        op-wsl-proxy
        wsl-ssh-agent
      ];

      programs.fish = {
        shellInit = ''
          replay "${wslAgentScript}"
        '';
      };
    })

    (mkIf cfg.enable {
      home-manager.users.mavy.home.sessionVariables = {
        SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      };
      home-manager.users.rkoens.home.sessionVariables = {
        SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      };
    })
  ];
}
