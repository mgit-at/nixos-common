{ config, pkgs, lib, ... }:

with lib;

{
  options.networking.ethtool-setringmax = mkEnableOption "ethtool-setringmamx" // { default = true; };

  config = mkIf (config.networking.ethtool-setringmax) {
    systemd.services.ethtool-setringmax = {
      after = [ "network.target" ];#
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Description = "Set Ring Parameters for Network Interfaces";
        Type = "oneshot";
        ExecStart = getExe pkgs.ethtool-setringmax;
        RemainAfterExit = true;
      };
    };
  };
}
