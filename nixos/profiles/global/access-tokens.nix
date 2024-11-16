{ lib, config, pkgs, nixpkgs, self, ... }:
{
  nix.extraOptions = ''
    !include ${config.sops.templates."nix-extra-config".path}
  '';
  nix.checkConfig = false;
  sops.templates."nix-extra-config" = {
    content = ''
      access-tokens = github.com=${config.sops.placeholder."github-token"}
    '';
    mode = "0440";
  };
}
