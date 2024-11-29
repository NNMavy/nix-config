{ source
, lib
, pkgs
, installShellFiles
}:
let
  buildGoModule = pkgs.buildGoModule.override { inherit (pkgs.unstable) go; };
in
buildGoModule rec {
  inherit (source) pname version src;

  ldflags = [
    "-s"
    "-w"
  ];

  vendorHash = "sha256-7cx+ys9CqL8Yjy1Jd1iXSfmlfG9yCNckhOId5EFqtQc=";

  # This is needed to deal with workspace issues during the build
  overrideModAttrs = _: { GOWORK = "off"; };
  GOWORK = "off";

  subPackages = [ "cmd/omni" ];

  nativeBuildInputs = [ installShellFiles ];

  # postInstall = ''
  #   installShellCompletion --cmd talosctl \
  #     --bash <($out/bin/talosctl completion bash) \
  #     --fish <($out/bin/talosctl completion fish) \
  #     --zsh <($out/bin/talosctl completion zsh)
  # '';

  doCheck = false; # no tests

  meta = with lib; {
    description = "The Sidero Omni Kubernetes management platform";
    mainProgram = "omni";
    homepage = "https://omni.siderolabs.com/";
    license = licenses.bsl11;
  };
}
