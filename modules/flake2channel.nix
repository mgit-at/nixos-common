{ inputs, config, lib, ... }: let
  filterSelf = inp: lib.filterAttrs # this prevents including the customer's ansible repo, which may contain bare secrets
    (name: _: name != "self")
    inp;
in {
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) (filterSelf inputs));

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    }) (filterSelf config.nix.registry);
}
