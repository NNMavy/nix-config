{ config, ... }:
let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{

  sops.age.sshKeyPaths = map getKeyPath keys;
  # Secret for machine-specific telegram
  sops.secrets."services/telegram/env" = {
    sopsFile = ./secrets.sops.yaml;
  };
  # sops.secrets.pushover-user-key = {
  #   sopsFile = ./secrets.sops.yaml;
  # };
  # sops.secrets.pushover-api-key = {
  #   sopsFile = ./secrets.sops.yaml;
  # };

}
