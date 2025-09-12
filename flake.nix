{
  description = "Common modules and packages used across mgit nixos configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.patches4nixpkgs.url = "github:mgit-at/patches4nixpkgs/master";
  inputs.mgit-exporter.url = "github:mgit-at/prometheus-mgit-exporter/topic/nixos";
  inputs.mgit-exporter.inputs.nixpkgs.follows = "nixpkgs";
  inputs.mgit-exporter.inputs.patches4nixpkgs.follows = "patches4nixpkgs";
  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nix-unify, disko, patches4nixpkgs, mgit-exporter, ... }@inputs: with inputs.nixpkgs.lib; let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    patchPkgs = patches4nixpkgs.patch inputs.nixpkgs [ mgit-exporter self ];
    nixpkgs = patches4nixpkgs.eval patchPkgs;
  in {
    overlays.default = final: prev:
      (import ./overlay.nix final prev) // (inputs.mgit-exporter.overlays.default final prev);

    inherit nixpkgs;

    patches4nixpkgs = nixpkgs: [
      [
        true
        ./patches/prometheus-exporter-errors.patch
      ]
    ];

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
        mgit-exporter = inputs.mgit-exporter.nixosModules.prometheus-mgit-exporter;
        nix-index = inputs.nix-index-database.nixosModules.nix-index;

        default = [
          ({
            nix.registry.nixpkgs.flake = nixpkgs.lib.mkForce inputs.nixpkgs;
            nix.registry.nixpkgs.to = nixpkgs.lib.mkForce {
              path = inputs.nixpkgs;
              type = "path";
              narHash = inputs.nixpkgs.narHash;
              lastModified = inputs.nixpkgs.lastModified;
            };
          })
          apt
          ansible-host
          base-tools
          flake2channel
          nixSettings
          defaults
          ethtool-setringmax
          prometheus-exporter-gateway
          mailcow
          mgit-exporter
          nix-index
          nix-index-extra
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
        incus_base = import ./os/incus/configuration.nix;
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

        ansibleDevShell = pkgs.mkAnsibleDevShell { };
        ansibleDevShellVersioned = pkgs.mkAnsibleDevShell { ansible = pkgs.ansible_2_18; };

        ansibleDevShellExtra = pkgs.mkAnsibleDevShell {
          extraAnsiblePy = [ "zstd" ];
        };
      }
    );

    nixosConfigurations = {
      hcloud = nixpkgs.lib.nixosSystem {
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

      incus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.inputs = inputs;
        modules = self.nixosModules.default ++ [
          (import ./os/incus/initial.nix)
          ({
            nixpkgs.overlays = [ self.overlays.default ];
          })
        ];
      };

      bazelisk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.inputs = inputs;
        modules = self.nixosModules.default ++ [
          (import ./os/bazelisk/configuration.nix)
          ({
            nixpkgs.overlays = [ self.overlays.default ];
          })
        ];
      };
    };

    templates.default = {
      path = ./template;
      description = "Default mgit nixos+ansible configuration";
    };
  };
}
