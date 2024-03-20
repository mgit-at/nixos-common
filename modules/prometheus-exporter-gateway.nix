{ config, pkgs, lib, ... }:

with lib;

let
  enabledExporters = filterAttrs (_: c: isAttrs c && c.enable) config.services.prometheus.exporters;
in
{
  options.mgit.prometheusExporterGateway = {
    rootCA = mkOption {
      type = types.str;
      description = "CA to validate incoming tls client connections";
    };
  };

  config = mkIf (enabledExporters != {}) {
    networking.firewall.allowedTCPPorts = [ 9443 ];
    services.nginx.virtualHosts."prometheus_exporter_gateway" = {
      listen = [
        { ssl = true; port = 9443; addr = "[::]"; }
      ];
      locations = mapAttrs' (exporter: exporterConf:
        (nameValuePair "/${exporter}/" {
          proxyPass = "http://localhost:${toString exporterConf.port}";
        })
      ) enabledExporters;
    };
  };
}
