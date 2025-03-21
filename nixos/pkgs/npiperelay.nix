{ lib
, pkgs
, buildGoModule
, ...
}:
let
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  packageData = sourceData.npiperelay;
in
buildGoModule rec {
  inherit (packageData) pname version src;

  ldflags = [ "-s" "-w" ];
  vendorHash = null;

  # Remember who we build this for
  # can't specify as attr beacuse it'll get overriden
  preBuild = ''
    export GOOS=windows
  '';

  # fixupPhase in Nix will mess up the binary it seems :(
  dontFixup = true;
  doCheck = false; # no tests

  postInstall = ''
    mv $out/bin/windows_amd64/* $out/bin
    rmdir $out/bin/windows_amd64
  '';
}
