# Fundamental differences between ansible and nixos

Ansible is "all the commands (tasks) to get from initial state to wanted state"

NixOS is "all the information to build the wanted state and a script to replace the current state with the wanted state (switch-to-configuration.pl, activationScripts)"

# Structure

Wheras in ansible you would write this to install `htop`...

```yaml
- name: Install htop
  ansible.builtin.apt:
    name:
      - htop
    state: present
```

...and then this to remove htop

```yaml
- name: Install htop                   
  ansible.builtin.apt:
    name:
      - htop
    state: absent
```

...and gradually execute tasks to get from a to b and also write the reverse path for removal if needed...

...and then run a playbook that calls the role with `ansible-playbook playbooks/my-playbook.yaml`

In nixos you write...

```nix
[ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
  ];
}
```

...to tell nix it should make htop part of the system path...

...and then build and deploy a system flake using `nixos-rebuild switch --flake .#my-host --target-host root@my-target-host`

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

```nix
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
