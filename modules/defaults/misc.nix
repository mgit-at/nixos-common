{
  security.sudo.enable = false;
  users.mutableUsers = false;
  networking.useDHCP = true;

  # todo: su exec only possible in root group

  # firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;

  # lock-out protection
  networking.firewall.allowedTCPPorts = [ 22 ];
}
