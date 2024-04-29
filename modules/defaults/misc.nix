{ lib, pkgs, ... }:

with lib;

{
  security.sudo.enable = false;
  users.mutableUsers = false;
  boot.initrd.systemd.enable = true;
  powerManagement.cpuFreqGovernor = mkDefault "performance";

  # todo: su exec only possible in root group

  # check if reboot needed after update - creates /run/reboot-required
  system.activationScripts.zz-needsreboot.text = ''
    ${getExe pkgs.nixos-needsreboot} >/dev/null
  '';

  # network
  networking.useDHCP = false;
  networking.useNetworkd = true;

  # firewall
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = false;

  # lock-out protection
  services.openssh.openFirewall = true;

  services.fstrim.enable = true;
}
