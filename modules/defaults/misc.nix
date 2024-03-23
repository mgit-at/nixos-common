{
  security.sudo.enable = false;
  users.mutableUsers = false;
  boot.initrd.systemd.enable = true;

  # todo: su exec only possible in root group

  # network
  networking.useDHCP = true;
  networking.useNetworkd = true;

  # firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = false;

  # lock-out protection
  networking.firewall.allowedTCPPorts = [ 22 ];
}
