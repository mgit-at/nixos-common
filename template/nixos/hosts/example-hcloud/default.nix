{ config, pkgs, lib, inputs, ... }:

with lib;

{
  imports = [
    ../../common/.
    inputs.common.nixosModules.hcloud_base
  ];

  # replace this address with the one assigned to your instance
  mgit.hcloud.auto-network = "2a01:4f8:aaaa:bbbb::2/64";

  networking.hostName = "example-hcloud";
  system.stateVersion = "24.05";
}
