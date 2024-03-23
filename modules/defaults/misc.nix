{
  security.sudo.enable = false;
  users.mutableUsers = false;
  networking.useDHCP = true;
  networking.useNetworkd = true;
  boot.initrd.systemd.enable = true;

  # todo: su exec only possible in root group

  # firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = false;

  # lock-out protection
  networking.firewall.allowedTCPPorts = [ 22 ];
}
