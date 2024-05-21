{
  lib,
  config,
  pkgs,
  ...
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
in {
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
        _1password.enable = true;
        _1password-gui = {
          enable = true;
          polkitPolicyOwners = ["mavy"];
        };
      };

      # autostart 1password
      home-manager.users.mavy.home.file.".config/autostart/1password.desktop".text = builtins.readFile "${pkgs._1password-gui}/share/applications/1password.desktop";
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
    })
  ];
}
