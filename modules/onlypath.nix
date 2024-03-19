# nix-unify config to share only path
{ lib, ... }:

with lib;

{
  imports = [
    ./base-tools.nix
  ];

  nix-unify.modules = {
    mergePath.enable = true;

    useNixDaemon.enable = false;
    shareUsers.enable = false;
    shareSystemd.enable = false;
  };

  system.build.etc = mkForce pkgs.writeText "removed" "onlypath profile active";

  system.extraSystemBuilderCmds = ''
    rm -f $out/sw $out/etc
  '';
}
