{
  description = "Common modules and packages used across mgit nixos configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-unify, disko }@inputs: with nixpkgs.lib; let
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
      in modules // (with modules; rec {
        default = [
          ansible-host
          base-tools
          flake2channel
          nixSettings
          defaults
          ethtool-setringmax
          prometheus-exporter-gateway
          mailcow
        ];
        ansible_default = default ++ [
          nix-unify.nixosModules.ansible
          from_ansible
        ];
        unify_default = ansible_default ++ [
          nix-unify.nixosModules.unify
        ];
        onlypath_default = [
          nix-unify.nixosModules.unify
          onlypath
        ];
        hcloud_base = import ./os/hcloud/configuration.nix disko;
        _disko = disko.nixosModules.disko;
      });

    checks = forAllSystems (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        });
      in
      (mapAttrs
        (key: _: pkgs.testers.runNixOSTest ((import "${./.}/tests/${key}") inputs self.nixosModules))
        (builtins.readDir ./tests)) //
      {
        onlypath = (pkgs.nixos {
          imports = self.nixosModules.onlypath_default;
          nixpkgs.hostPlatform = system;
        }).config.system.build.toplevel;

        # check if our ansible set evaluates without any ansible stuff set
        # (this allows better ci testing)
        ansible = (import "${nixpkgs}/nixos/lib/eval-config.nix" {
          modules = [
            {
              imports = self.nixosModules.ansible_default;
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [ self.overlays.default ];
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
              boot.loader.systemd-boot.enable = true;
              users.allowNoPasswordLogin = true;
            }
          ];

          # this needs to be set via pkgs.nixos,
          # but there's no way to do that
          specialArgs = {
            inherit inputs;
          };

          system = null;
        }).config.system.build.toplevel;

        ansibleDevShell = pkgs.mkAnsibleDevShell {};
      }
    );

    nixosConfigurations.hcloud = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.inputs = inputs;
      modules = self.nixosModules.default ++ [
        (import ./os/hcloud/configuration.nix disko)
        ({
          users.users.root.password = "mgitsetup";
          services.openssh.settings.PermitRootLogin = "yes";
          nixpkgs.overlays = [ self.overlays.default ];
          networking.useDHCP = nixpkgs.lib.mkForce true;
        })
      ];
    };

    templates.default = {
      path = ./template;
      description = "Default mgit nixos+ansible configuration";
    };
  };
}
