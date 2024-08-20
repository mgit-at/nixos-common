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

      programs.apt = {
        enable = true;
        fakePackages = [ "fake-package" ];
      };

      environment.etc."test.deb".source = deb;
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("apt-setup")
    server.succeed("apt install /etc/test.deb -y")
    server.succeed("test -e /usr/share/doc/gcc-12-base/copyright")
    server.succeed("apt-cache show fake-package")
    server.succeed("apt remove fake-package -y")
    server.fail("apt-cache show fake-package")
    server.fail("apt-cache show fake-package-2")
    server.succeed("apt-mock-packages fake-package-2")
    server.succeed("apt-cache show fake-package-2")
  '';
}
