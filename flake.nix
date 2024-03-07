{
  description = "Common modules and packages used across mgit nixos configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules = with nixpkgs.lib;
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
