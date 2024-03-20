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
    networking.firewall.allowedTCPPorts = [ 9000 ];
    services.nginx.virtualHosts."prometheus_exporter_gateway" = {
      listen = [
        { ssl = true; port = 9000; addr = "[::]"; }
      ];
      sslCertificate = "/var/lib/secrets/prom.cert.pem";
      sslCertificateKey = "/var/lib/secrets/prom.key.pem";
      extraConfig = ''
        ssl_client_certificate /var/lib/secrets/client.ca.pem;
      '';
      locations = (mapAttrs' (exporter: exporterConf:
        (nameValuePair "= /${exporter}" {
          proxyPass = "http://localhost:${toString exporterConf.port}/metrics";
        })
      ) enabledExporters) // {
        "/" = {
          root = pkgs.writeTextDir "index.html" ''
            <!doctype html>
            <head>
              <title>prometheus exporters for ${config.networking.hostName}</title>
            </head>
            <body>
              ${concatMapStringsSep "\n" (name: "<a href=\"/${name}\">${name} exporter</a>") (attrNames enabledExporters)}
            </body>
          '';
          index = "index.html";
        };
      };
    };
  };
}
