{
  lib,
  pkgs,
  ...
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "npiperelay";
  version = "0.1.0";

  src = pkgs.fetchzip {
    url = "https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip";
    hash = "sha256-GcwreB8BXYGNKJihE2xeelsroy+JFqLK1NK7Ycqxw5g=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv npiperelay.exe $out/bin
  '';
}
