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
      home-manager.users.mavy.programs = {
        ssh.extraConfig = ''
          IdentityAgent "~/.1password/agent.sock"
        '';
        git.extraConfig = {
          gpg = {
            format = "ssh";
            ssh = {
              allowedSignersFile = "~/.ssh/allowed_signers";
              program = "/mnt/c/Program Files/1Password/app/8/op-ssh-sign.exe";
            };
          };
        };
      };

      home-manager.users.mavy.home.packages = [
        op-wsl-proxy
      ];

      systemd.user.services.opagent-relay = {
        description = "OPAgent SSH_AUTH_SOCK relay using npiperelay.exe";
        after = [ "default.target" ];
        wantedBy = [ "default.target" ];
        environment.PATH = lib.mkForce "/run/current-system/sw/bin:${pkgs.systemd}/bin:${pkgs.npiperelay}/bin";

        serviceConfig = {
          Restart = "always";
          Type = "simple";
          ExecStartPre = "/run/current-system/sw/bin/rm -Rf %h/.1password/agent.sock";
          ExecStart = let
            nprArgs = builtins.concatStringsSep " " [
              "-ei" # Terminate on EOF from stdin
              "-ep" # Terminate on EOF from pipe
              "-p" # Poll until pipe available
              "-s" # Send 0-byte message on EOF from stdin
              "-v" # Verbose output on stderr
            ];
            nprCmdline = "npiperelay.exe ${nprArgs} //./pipe/openssh-ssh-agent";

            wslSide = "UNIX-LISTEN:%h/.1password/agent.sock,fork,umask=007";
            windowsSide = "EXEC:${nprCmdline},nofork"; # avoid escaping
          in
            "${pkgs.socat}/bin/socat '${wslSide}' '${windowsSide}'";
        };
      };
    })

    (mkIf cfg.enable {
      home-manager.users.mavy.home.sessionVariables = {
        SSH_AUTH_SOCK = "~/.1password/agent.sock";
      };
    })
  ];
}
