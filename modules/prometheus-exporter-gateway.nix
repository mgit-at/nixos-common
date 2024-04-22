{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.mgit.exporters;
  enabledExporters = (mapAttrs (_: conf: conf.port)
    (filterAttrs (_: c: isAttrs c && c.enable) config.services.prometheus.exporters))
    // cfg.extraPorts;
in
{
  options.mgit.exporters = {
    enable = mkEnableOption "mgit prometheus nginx exporter" // { default = true; };

    extraPorts = mkOption {
      type = types.attrsOf types.port;
      description = "Extra ports to add to nginx config";
      default = {};
      example = { cilium = 9962; };
    };
  };

  config = mkIf (cfg.enable && enabledExporters != {}) {
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
      locations = (mapAttrs' (exporter: port:
        (nameValuePair "= /${exporter}" {
          proxyPass = "http://localhost:${toString port}/metrics";
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
