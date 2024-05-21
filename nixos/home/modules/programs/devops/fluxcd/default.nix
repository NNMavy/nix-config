{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.myHome.programs.fluxcd;

in
{
  options.myHome.programs.fluxcd = {
    enable = mkEnableOption "fluxcd";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fluxcd
    ];

    programs.fish = {
      interactiveShellInit = ''
        # ${pkgs.fluxcd}/bin/flux completion fish > ${config.home.homeDirectory}/.config/fish/completions/flux.fish
        eval (${pkgs.fluxcd}/bin/flux completion fish)
      '';
      functions = {
        commit = {
          description = "git conventional commits";
          body = builtins.readFile ./functions/commit.fish;
        };
        flretry = {
          description = "Retry a flux update";
          body = builtins.readFile ./functions/flretry.fish;
        };
      };
    };
  };
}
