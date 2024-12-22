{ source
, lib
, pkgs
, buildGoModule
, ...
}:
buildGoModule rec {
  inherit (source) pname version src;

  ldflags = [ "-s" "-w" ];
  vendorHash = "sha256-18Fzld2F05hzORw8kLt6JdCdxGNM+KOEUiPnC3LTzDI=";
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
