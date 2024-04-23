{
  services.prometheus.exporters = {
    node.extraFlags = [ "--web.listen-address=[::1]:9100" ];
  };
}
