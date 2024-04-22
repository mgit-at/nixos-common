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

    ansible-host.extraPyPackages = [ "cryptography" "pyopenssl" ];

    services.nginx.virtualHosts."prometheus_exporter_gateway" = {
      listen = [
        { ssl = true; port = 9000; addr = "[::]"; }
      ];
      onlySSL = true;
      sslCertificate = "/etc/ssl/prometheus-exporter/server-${config.networking.hostName}-chain.pem";
      sslCertificateKey = "/etc/ssl/prometheus-exporter/server-${config.networking.hostName}-key.pem";
      extraConfig = ''
        ssl_client_certificate /etc/ssl/prometheus-exporter/prom-exporter-ca.pem;
      '';
      locations = (mapAttrs' (exporter: exporterConf:
        (nameValuePair "= /${exporter}" {
          proxyPass = "http://localhost:${toString exporterConf.port}/metrics";
        })
      ) enabledExporters) // {
        "/" = {
          root = pkgs.writeTextDir "index.html" ''
            <!DOCTYPE html>
            <html>
                <head>
                    <meta charset="UTF-8">
                    <title>Prometheus Metrics for ${config.networking.hostName}</title>
                    <style>
                      ul {
                        list-style-type: "» ";
                      }

                      body {
                        font-family: sans-serif;
                      }
                    </style>
                </head>
                <body>
                    <h1>Prometheus Metrics for ${config.networking.hostName}</h1>
                    <ul>
                        ${concatMapStringsSep "\n" (name: " <li><a href=\"/${name}\">${name}</a></li>") (attrNames enabledExporters)}
                    </ul>
                </body>
            </html>
          '';
          index = "index.html";
        };
      };
    };
  };
}
