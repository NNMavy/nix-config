{ pkgs
, lib
, stdenv
, fetchFromGitHub
, rustPlatform
, makeBinaryWrapper
, cosmic-icons
, just
, pkg-config
, glib
, libxkbcommon
, wayland
, xorg
,
}:
let
  sourceData = pkgs.callPackage ./_sources/generated.nix { };
  packageData = sourceData.cosmic-idle;
in
rustPlatform.buildRustPackage rec {
  inherit (packageData) pname version src;

  cargoLock = source.cargoLock."Cargo.lock";

  # COSMIC applications now uses vergen for the About page
  # Update the COMMIT_DATE to match when the commit was made
  env.VERGEN_GIT_COMMIT_DATE = "2024-08-05";
  env.VERGEN_GIT_SHA = src.rev;

  postPatch = ''
    substituteInPlace justfile --replace '#!/usr/bin/env' "#!$(command -v env)"
  '';

  nativeBuildInputs = [ just pkg-config makeBinaryWrapper ];
  buildInputs = [ glib libxkbcommon wayland ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-idle"
  ];

  # LD_LIBRARY_PATH can be removed once tiny-xlib is bumped above 0.2.2
  postInstall = ''
    wrapProgram "$out/bin/cosmic-idle" \
      --suffix XDG_DATA_DIRS : "${cosmic-icons}/share" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXi wayland]}
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-idle";
    description = "File Manager for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ahoneybun nyabinary ];
    platforms = platforms.linux;
  };
}
