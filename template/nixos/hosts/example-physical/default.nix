{ config, pkgs, lib, inputs, ... }:

with lib;

{
  imports = [
    ../../common/.

    disko.nixosModules.disko
    # See examples https://github.com/nix-community/disko/tree/master/example
    ./disko.nix
    # Generated from nixos-generate-config on iso
    ./hardware-configuration.nix
    ({
      # Devices disko will touch. Adjust.
      _module.args.disks = [ "/dev/sdX" ];
    })
  ];

  # Use this to rename enpXXX back to eth0 (optional):
  # networking.usePredictableInterfaceNames = false;

  # Network.
  systemd.network = {
    enable = true;
    # Substitute with machine's interface name.
    networks."40-enp195s0" = {
      matchConfig = {
        Name = "enp195s0";
      };
      gateway = [ "fe80::1" "1.2.3.99" ];
      networkConfig = {
        # Substitute machine's your address.
        Address = "2a01:4f8:aaaa:bbbb::2/128";
      };
      addresses = [
        { addressConfig = { Address = "1.2.3.99/26"; Peer = "1.2.3.1"; }; }
      ];
    };
  };

  # Demonstration of firewall, adjust to your needs.
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ];
  };
}
