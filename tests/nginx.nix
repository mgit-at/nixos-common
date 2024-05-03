inputs: mod: { ... }:
{
  name = "nginx";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { pkgs, ... }: {
      imports = mod.default;
      services.nginx.enable = true;

      environment.systemPackages = with pkgs; [
        curl
      ];
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("nginx")
    server.execute("curl localhost | grep 'This domain is not configured on this server. Please contact your administrator if this seems wrong.'")
  '';
}
