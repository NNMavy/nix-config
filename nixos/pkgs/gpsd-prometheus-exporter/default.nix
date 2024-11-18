{ source, pkgs, lib, stdenv, python39, fetchFromGitHub }:
let
  sources = (import ../_sources/generated.nix) { inherit (pkgs) fetchurl fetchgit fetchFromGitHub dockerTools; };
  gpsSource = sources.python-gps;

  packageOverrides = self: super: {
    gps = super.buildPythonPackage rec {
      inherit (gpsSource) pname version src;
      doCheck = false;

      meta = with lib; {
        homepage = "https://gitlab.com/gpsd/gpsd";
        description = "GPSD client";
      };
    };
  };

  python = python39.override { inherit packageOverrides; };

  pyEnv = python.withPackages (ps: [
    ps.gps
    ps.prometheus-client
    ps.setuptools
  ]);
in
stdenv.mkDerivation rec {
  inherit (source) pname version src;

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
