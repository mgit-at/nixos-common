{
  description = "Common modules and packages used across mgit nixos configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }: with nixpkgs.lib; {
    overlays.default = import ./overlay.nix;

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };
      folder = builtins.readDir ./pkgs;
    in {
      default = pkgs.releaseTools.aggregate {
        name = "mgit-nixos-pkgs";

        constituents = mapAttrsToList (pkg: _: pkgs.${pkg}) folder;
      };
    } // (mapAttrs (pkg: _: pkgs.${pkg}) folder);

    nixosModules =
      let
        modules = mapAttrs' (key: _:
          nameValuePair
            (removeSuffix ".nix" key)
            (import "${./modules}/${key}")
        ) (builtins.readDir ./modules);
      in modules // (with modules; {
        default = [
          flake2channel
          nixSettings
        ];
      });
  };
}
