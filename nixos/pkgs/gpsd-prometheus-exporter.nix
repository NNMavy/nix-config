{ pkgs, lib, stdenv, python3, fetchFromGitHub }:
let
  pyEnv = python3.withPackages (ps: [
    ps.prometheus-client
    ps.setuptools
  ]);
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  packageData = sourceData.gpsd-prometheus-exporter;
in
stdenv.mkDerivation rec {
  inherit (packageData) pname version src;

  doCheck = false;

  pyWrapped = pyEnv.interpreter;

  buildInputs = [
    pyEnv
  ];

  installPhase = ''
    install -Dm755 ./gpsd_exporter.py $out/bin/gpsd_exporter.py
  '';

  meta = with lib; {
    homepage = "https://github.com/brendanbank/gpsd-prometheus-exporter";
    description = "Prometheus exporter for the gpsd GPS daemon. Collects metrics from the GPSD deamon. =";
  };
}
