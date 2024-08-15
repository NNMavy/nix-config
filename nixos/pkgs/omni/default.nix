{ lib, buildGoModule, fetchFromGitHub, installShellFiles}:
buildGoModule rec {
  inherit (source) pname version src vendorSha256;

  ldflags = [ "-s" "-w" ];

  env.GOWORK = "off";

  subPackages = [ "cmd/omni" ];

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false; # no tests

  meta = with lib; {
    description = "The Sidero Omni Kubernetes management platform";
    mainProgram = "omni";
    homepage = "https://omni.siderolabs.com/";
    license = licenses.bsl11;
    maintainers = with maintainers; [ nnmavy ];
  };
}
