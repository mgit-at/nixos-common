{
  description = "Repository for mgIT internal servers (and some smaller customers without an own Ansible repository)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.common.url = "github:mgit-at/nixos-common/master";
  inputs.common.inputs.nixpkgs.follows = "nixpkgs";
  inputs.common.inputs.nix-unify.follows = "nix-unify";

  outputs = { self, nixpkgs, nix-unify, common }@inputs: let
    inherit (self) outputs;
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs (host: _: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        ({
          nixpkgs.overlays = [
            common.overlays.default
            (import ./nixos/common/overlay.nix)
            # add extra global overlays here
          ];
        })
        "${./.}/nixos/hosts/${host}"
        # add extra global modules here
      ];
    }) (builtins.readDir ./nixos/hosts);

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          common.overlays.default
        ];
      };
    in {
      default = pkgs.mkAnsibleDevShell {};
    });
  };
}
