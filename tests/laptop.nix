inputs: mod: { ... }:
{
  name = "laptop";

  nodes =
    inputs.nixpkgs.lib.mapAttrs (key: nix: { config, pkgs, lib, ... }: {
      imports = [ nix ];
      nix.package = lib.mkForce pkgs.nixVersions.latest;
    }) mod.laptop;

  testScript = ''
    # do nothing here, we just want everything to build
  '';
}
