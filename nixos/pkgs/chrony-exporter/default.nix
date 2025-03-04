{ source
, lib
, pkgs
, buildGoModule
, ...
}:
buildGoModule rec {
  inherit (source) pname version src;

  ldflags = [ "-s" "-w" ];
  vendorHash = "sha256-3zL7BrCdMVnt7F1FiZ2eQnKVhmCeW3aYKKX9v01ms/k=";
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
