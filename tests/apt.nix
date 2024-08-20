inputs: mod: { pkgs, ... }:
let
  deb = pkgs.fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-12/gcc-12-base_12.3.0-9ubuntu2_amd64.deb";
    hash = "sha256-rbKmrgkr/WwJevjAaSnSL9Xy9NhMl04OE9GIil3tBNs=";
  };
in
{
  name = "default-os";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { pkgs, ... }: {
      imports = mod.default;

      programs.apt.enable = true;

      environment.etc."test.deb".source = deb;
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("ethtool-setringmax")
    server.succeed("apt install /etc/test.deb -y")
    server.succeed("test -e /usr/share/doc/gcc-12-base/copyright")
  '';
}
