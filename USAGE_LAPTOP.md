# Adding laptop configuration

We provide nixos base configurations that install all necesarry things such as git, git ansible integration or dev tools.

There are three available configs:
- base: Tools needed for all teams (git, docker, etc.)
- devops: base + Tools and integrations for deployments (ansible, etc.)
- dev: base + Tools for development (go, etc.)

## Installation (flakes)

This method uses the special args method for convinience

#### In flake.nix, add to inputs:
```nix
inputs.mgit.url = "github:mgit-at/nixos-common/master";
inputs.mgit.inputs.nixpkgs.follows = "nixpkgs";
```

#### Modify outputs in flake.nix:

before:
```nix
{
  outputs = { nixpkgs }: {
    # your stuff...
  };
}
```

after:

```nix
{
  outputs = { self, nixpkgs, ... } @inputs: let # add self and @inputs, start a let
    inherit (self) outputs; # add this
  in # end the let
  {
    # your stuff...
  };
}
```

#### Modify all nixosConfigurations in flake.nix:

before:
```nix
{
  nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
    modules = [
      # your stuff...
    ];
  };
}
```

after:
```nix
{
  nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs outputs;}; # add this
    modules = [
      # your stuff...
    ];
  };
}
```

#### Add to one of your configuration files:

before:

```nix
{ config, pkgs, lib, ... }: {
  imports = [
    # your stuff...
  ];

  nixpkgs.overlays = [
    # your stuff...
  ];

  # your stuff...
}
```

after:

```nix
{ inputs, config, pkgs, lib, ... }: { # add inputs here
  imports = [
    inputs.mgit.nixosModules.laptop.all # or devops, or dev
    # your stuff...
  ];

  nixpkgs.overlays = [
    inputs.mgit.overlays.default
    # your stuff...
  ];

  # your stuff...
}
```
