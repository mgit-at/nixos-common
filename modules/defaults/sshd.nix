{ config, lib, ... }:

with lib;
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = mkDefault "without-password";
      PubkeyAuthentication = true;
      IgnoreRhosts = true;
      HostbasedAuthentication = false;
      PermitEmptyPasswords = false;
      UseDns = false;
      UsePAM = mkDefault true;
    };
  };
}
