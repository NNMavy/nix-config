{ pkgs
, lib
, buildGoModule
, ...
}:
let
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  hashData = lib.importJSON ./_sources/vendorhash.json;
  packageData = sourceData.adguard-exporter;
in
buildGoModule rec {
  inherit (packageData) pname version src;

  ldflags = [ "-s" "-w" ];
  vendorHash = hashData.adguard-exporter;
  outputs = [ "out" ];

  # # This is needed to deal with workspace issues during the build
  # overrideModAttrs = _: { GOWORK = "off"; };
  # GOWORK = "off";

  preBuild = ''
    export CGO_ENABLED=0
  '';

  doCheck = false; # no tests

  # postInstall = ''
  #   mkdir -p $out/bin
  #   mv $out/adguard-exporter $out/bin
  # '';
}
