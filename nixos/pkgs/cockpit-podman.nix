{ source, lib, stdenv, fetchzip, gettext }:
let
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  packageData = sourceData.cockpit-podman;
in
stdenv.mkDerivation rec {
  inherit (packageData) pname version src vendorSha256;

  nativeBuildInputs = [
    gettext
  ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share $out/share
    touch pkg/lib/cockpit-po-plugin.js
    touch dist/manifest.json
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for podman containers";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-podman";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
