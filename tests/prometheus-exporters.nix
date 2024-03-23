inputs: mod: { pkgs, lib, ... }:
{
  name = "prometheus-exporters";

  node.specialArgs.inputs = inputs;

  nodes = {
    source = { lib, pkgs, ... }: {
      imports = mod.default;

      # services.nginx.enable = true;
      services.prometheus.exporters.node.enable = true;
    };

    monitoring = { lib, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        curl
      ];
    };
  };

  testScript = ''
    start_all()
    # source.wait_for_unit("nginx")
    # monitoring.execute("curl https://source:9000")
  '';
}
