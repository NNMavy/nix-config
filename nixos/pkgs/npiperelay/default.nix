{ source
, lib
, pkgs
, buildGoModule
, ...
}:
buildGoModule rec {
  inherit (source) pname version src;

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
