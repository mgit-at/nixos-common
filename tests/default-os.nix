inputs: mod: { ... }:
{
  name = "default-os";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { ... }: {
      imports = mod.default;
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("ethtool-setringmax")
    server.fail("lsmod | grep sctp")
  '';
}
