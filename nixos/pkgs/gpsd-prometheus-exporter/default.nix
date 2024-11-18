
{ source, pkgs, lib, stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  inherit (source) pname version src;

  propagatedBuildInputs = [
    (with pkgs.python3Packages; [
      prometheus-client
      gps3
    ])
  ];

  doCheck = false;
  installPhase = "install -Dm755 ./gpsd_exporter.py $out/bin/gpsd_exporter.py";

  meta = with lib; {
    homepage = "https://github.com/brendanbank/gpsd-prometheus-exporter";
    description = "Prometheus exporter for the gpsd GPS daemon. Collects metrics from the GPSD deamon. =";
  };
}
