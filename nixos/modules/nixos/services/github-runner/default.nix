{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "github-runner";
  runnerName = "nix-config";
  category = "services";
  description = "Self hosted github runner";
  user = "root"; #string
  group = "root"; #string
  appFolder = "/var/lib/${app}";
  host = "${app}" + (if cfg.dev then "-dev" else "");
  url = "${host}.${config.networking.domain}";
in
{
  options.mySystem.${category}.${app} =
    {
      enable = mkEnableOption "${app}";
    };

  config = mkIf cfg.enable {

    ## Secrets
    sops.secrets."services/github-runner/token" = {
      sopsFile = ./secrets.sops.yaml;
      owner = user;
      restartUnits = [ "${app}.service" ];
    };

    users.users.mavy.extraGroups = [ group ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [
        { directory = appFolder; inherit user; inherit group; mode = "750"; }
      ];
    };

    services.github-runners = {
      "${runnerName}-1" = {
        name = "${runnerName}";
        enable = true;
        replace = true;
        ephemeral = false;
        inherit user;
        inherit group;
        tokenFile = config.sops.secrets."services/github-runner/token".path;
        url = "https://github.com/NNMavy/nix-config";
        serviceOverrides.StateDirectory = [
          "github-runner/${runnerName}-1" # module default
          "github-runner-work/${runnerName}-1"
        ];
        nodeRuntimes = [ "node20" ];
        extraPackages = with pkgs; [
          gh
          docker
          gawk
          nix
        ];
        workDir = "/var/lib/github-runner-work/${runnerName}-1";
        extraLabels = [ runnerName ];
        extraEnvironment = {
          NIX_PATH = "/nix/var/nix/profiles/per-user/root/channels/nixos";
          LIBRARY_PATH = "${pkgs.libxkbcommon}/lib";
        };
      };
      "${runnerName}-2" = {
        name = "${runnerName}";
        enable = true;
        replace = true;
        ephemeral = false;
        inherit user;
        inherit group;
        tokenFile = config.sops.secrets."services/github-runner/token".path;
        url = "https://github.com/NNMavy/nix-config";
        serviceOverrides.StateDirectory = [
          "github-runner/${runnerName}-2" # module default
          "github-runner-work/${runnerName}-2"
        ];
        nodeRuntimes = [ "node20" ];
        extraPackages = with pkgs; [
          gh
          docker
          gawk
          nix
        ];
        workDir = "/var/lib/github-runner-work/${runnerName}-2";
        extraLabels = [ runnerName ];
        extraEnvironment = {
          NIX_PATH = "/nix/var/nix/profiles/per-user/root/channels/nixos";
          LIBRARY_PATH = "${pkgs.libxkbcommon}/lib";
        };
      };

    };

    programs.nix-ld.enable = true;
  };
}
