{ config, pkgs, lib, inputs, ... }:

with lib;

{
  imports = [
    inputs.nix-unify.nixosModules.unify
    ../../common/.
  ];

  systemd.network = {
    enable = true;
    networks."40-enp195s0" = {
      matchConfig = {
        Name = "enp195s0";
      };
      gateway = [ "fe80::1" "1.2.3.99" ];
      networkConfig = {
        Address = "2a01:4f8:aaaa:bbbb::2/128";
      };
      addresses = [
        { addressConfig = { Address = "1.2.3.99/26"; Peer = "1.2.3.1"; }; }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ];
  };

  nix-unify = {
    /* modules.shareSystemd.units = [
      "my.service"
      "my.timer"
    ]; */
    /* files.etc = {
      "my-folder" = {};
    }; */
    modules.shareNftables.enable = true;
    modules.shareNetworkd.enable = true;
  };
}
