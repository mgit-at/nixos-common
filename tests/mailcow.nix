inputs: mod: { pkgs, lib, ... }:
{
  name = "mailcow";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { lib, pkgs, ... }: {
      imports = mod.default;
      services.mailcow.enable = true;
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("docker")
  '';
}
