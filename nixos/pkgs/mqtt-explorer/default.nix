{ source, pkgs, stdenv, lib, appimageTools, electron_30, makeWrapper }:

stdenv.mkDerivation rec {
  inherit (source) pname version src;

  buildInputs = [ makeWrapper ];
  installPhase = ''
    install -m 444 -D resources/app.asar $out/libexec/app.asar
    install -m 444 -D mqtt-explorer.png $out/share/icons/mqtt-explorer.png
    install -m 444 -D mqtt-explorer.desktop $out/share/applications/mqtt-explorer.desktop
    makeWrapper ${electron_30}/bin/electron $out/bin/mqtt-explorer --add-flags $out/libexec/app.asar
  '';
  meta = with lib; {
    description = "A comprehensive and easy-to-use MQTT Client";
    homepage = "https://mqtt-explorer.com/";
    license = # TODO: make licenses.cc-by-nd-40
      { free = false; fullName = "Creative Commons Attribution-No Derivative Works v4.00"; shortName = "cc-by-nd-40"; spdxId = "CC-BY-ND-4.0"; url = "https://spdx.org/licenses/CC-BY-ND-4.0.html"; };
    maintainers = [ maintainers.yorickvp ];
    inherit (electron_30.meta) platforms;
  };
}
