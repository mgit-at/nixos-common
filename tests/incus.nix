inputs: mod: { pkgs, lib, ... }:
{
  name = "incus-test-vm";

  node.specialArgs.inputs = inputs;

  nodes = {
    server = { lib, pkgs, ... }: {
      virtualisation.memorySize = 2048;
      virtualisation.diskSize = 4096;

      # incus and our sysctl set this
      # both are mkDefault, so set explicitly
      # otherwise it errors as it is set twice
      boot.kernel.sysctl."kernel.dmesg_restrict" = 1;

      virtualisation.incus.enable = true;
      networking.firewall.trustedInterfaces = [ "incusbr*" ];

      imports = mod.default;
    };
  };

  testScript = ''
    start_all()
    server.succeed("incus admin init --minimal")
    server.succeed("incus image import ${inputs.self.nixosConfigurations.incus.config.system.build.metadata}/tarball/nixos-system-x86_64-linux.tar.xz ${inputs.self.nixosConfigurations.incus.config.system.build.squashfs} --alias incus-test")
    server.succeed("incus launch incus-test test-vm -c security.nesting=true")
    server.wait_until_succeeds("incus exec test-vm true")
    server.wait_until_succeeds("incus -f csv -c 4 ls | grep 10")
    _, ip = server.execute("incus -f csv -c 4 ls | grep -o '10[0-9.]*'")
    server.succeed(f"ssh -o StrictHostKeyChecking=no root@{ip.strip()} true")
  '';
}
