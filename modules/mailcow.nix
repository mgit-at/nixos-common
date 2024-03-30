{ config, pkgs, lib, inputs, ... }:

with lib;
let
  cfg = config.services.mailcow;
in
{
  options.services.mailcow = {
    enable = mkEnableOption "mailcow";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    networking.firewall.trustedInterfaces = [ "br-mailcow" "docker*" ];
    environment.systemPackages = with pkgs; [
      mailcow
    ];

    # mailcow docker native ipv6 nat
    virtualisation.docker.daemon.settings = {
      ipv6 = true;
      fixed-cidr-v6 = "fd00:dead:beef:c0::/80";
      experimental = true;
      ip6tables = true;
    };
    # convince the mailcow script we have enabled ipv6nat
    environment.etc."docker/daemon.json".text = ''
      {"ipv6":true,"fixed-cidr-v6":"fd00:dead:beef:c0::/80","experimental":true,"ip6tables":true}
    '';
  };
}
