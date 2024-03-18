# Fundamental differences between ansible and nixos

Ansible is "all the commands (tasks) to get from initial state to wanted state"

NixOS is "all the information to build the wanted state and a script to replace the current state with the wanted state (switch-to-configuration.pl, activationScripts)"

# Roles vs modules and option priorities

In ansible you call a role with arguments, which then executes a bunch of tasks

This would roughly translate 1:1 to this in nixos:

```nix
{
  imports = [
    (import base.nix {
       # overrides
       base_ssh_permit_root_login = "no"; 
       ...
    })
  ];
}
```

But this isn't the native nixos-style and there is a better solution available:

One module sets all the base defaults, let's call it `base.nix`

```
{ config, lib, ... }:

with lib; # to get mkDefault
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = mkDefault "without-password"; # default that will possibly be overriden
      PubkeyAuthentication = true; # default that shouldn't be overriden
      ...
    };
  };
}
```

In another module we can now set the overrides if needed, like so:

`services.openssh.settings.PermitRootLogin = "no";`

This will not fail, since the other value has the priority `default` (as in "an option default) instead of `normal` (the regular priority)

Note that overriding `PubkeyAuthentication` will fail, as two values will be present with `normal` priority (which is what we want. it can still be overriden using `mkForce`, but then it's clear that we intend that to be a bad idea)

(In practice the `nixos-common` repo has `modules/defaults/$service.nix` which define defaults per service)
