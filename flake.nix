{
  description = "Common modules and packages used across mgit nixos configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }@inputs: with nixpkgs.lib; let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    overlays.default = import ./overlay.nix;

    packages = forAllSystems (system:
      let
        pkgs = import "${nixpkgs}" {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        folder = builtins.readDir ./pkgs;
      in {
        default = pkgs.releaseTools.aggregate {
          name = "mgit-nixos-pkgs";

          constituents = mapAttrsToList (pkg: _: pkgs.${pkg}) folder;
        };
      } // (mapAttrs (pkg: _: pkgs.${pkg}) folder)
    );

    nixosModules =
      let
        modules = mapAttrs' (key: _:
          nameValuePair
            (removeSuffix ".nix" key)
            (import "${./modules}/${key}")
        ) (builtins.readDir ./modules);
      in modules // (with modules; {
        default = [
          base-tools
          flake2channel
          nixSettings
          defaults
        ];
      });

    checks = forAllSystems (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        });
      in
      mapAttrs
        (key: _: pkgs.testers.runNixOSTest ((import "${./.}/tests/${key}") inputs self.nixosModules))
        (builtins.readDir ./tests)
    );
  };
}
