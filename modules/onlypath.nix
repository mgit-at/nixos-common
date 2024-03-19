# nix-unify config to share only path
{ lib, pkgs, ... }:

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

  system.build.etc = mkForce ((pkgs.writeText "removed" "onlypath profile active") // { passthru.targets = []; });

  system.extraSystemBuilderCmds = ''
    rm -f $out/sw $out/etc
    ln -s ${pkgs.nix-unify.path} $out/sw
  '';
}
