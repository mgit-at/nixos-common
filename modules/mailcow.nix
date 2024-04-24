{ config, pkgs, lib, inputs, ... }:

with lib;
let
  cfg = config.services.mailcow;
  ini = pkgs.formats.ini {};
  json = pkgs.formats.json {};
in
{
  options.services.mailcow = {
    enable = mkEnableOption "mailcow";

    settings = mkOption {
      description = "Settings for mailcow";
      default = {};
      # get type for global section
      # type = ini.type.nestedTypes.elemType;
      type = types.attrsOf types.str;
      example = {
        "SKIP_CLAMD" = "y";
      };
    };
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

    environment.etc."mailcow.json".source =
      json.generate "mailcow.json" cfg.settings;

    # this breaks the mailcow internal monitoring during os upgrades, so turn it off
    virtualisation.docker.liveRestore = false;

    networking.firewall.allowedTCPPorts = [
      25
      80
      110
      143
      443
      465
      587
      993
      995
      3306
      4190
      6379
      8983
      12345
    ];
  };
}
