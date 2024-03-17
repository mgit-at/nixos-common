{ config, pkgs, lib, ... }:

with lib;

{
  systemd.services.ethtool-setringmax = {
    after = [ "network.target" ];#
    wantedBy = [ "multi-user.target" ];
    reloadIfChanged = true;
    serviceConfig = {
      Description = "Set Ring Parameters for Network Interfaces";
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool-setringmax}/bin/ethtool-setringmax";
      ExecReload = "${pkgs.ethtool-setringmax}/bin/ethtool-setringmax";
      RemainAfterExit = true;
    };
  };
}
