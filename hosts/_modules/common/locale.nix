{
  pkgs,
  lib,
  ...
}: {
  time.timeZone = lib.mkDefault "Europe/Amsterdam";
}
