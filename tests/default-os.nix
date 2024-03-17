inputs: mod: { pkgs, lib, ... }:
{
  name = "default-os";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { lib, pkgs, ... }: {
      imports = mod.default;
    };
  };

  testScript = ''
    start_all()
    server.execute("true")
  '';
}
