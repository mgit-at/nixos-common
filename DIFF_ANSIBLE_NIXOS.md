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

...and then this to remove htop...

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

# Why nixos and not ansible?

As you've seen in the above example:
- ansible assumes a pristine base state.

  Say ubuntu ships with different default packages and hetzner ubuntu also ships with differente default packages, and you try to install yet another package, that conflicts with one default packages, that you didn't even know about.

  This will fail and ansible will be none the wiser.
  It can be accounted for, but that's extra code.

  In nixos you have a clear overview of all the defaults and you can get rid of them easily.
- ansible doesn't have a removal routine "built-in" and leaves leftover state.
  While it's true that nixos doesn't either, removing something from the configuration in nixos also gets rid of it on the host, which is basically the same thing.

  On ansible everything stays, unless explicitly removed, thus collecting sources of undefined behaviour like: hosts deployed with role X before date Y will have leftover package Z and it's config, which will then need to be accounted for if version 2 of package Z will be installed)


- nixos has a "no pfusch" attitude

  You can't just do a quick hack that's not going via the git repo.
  You will at the very least need to edit the configuration, as /etc is fully read-only (with a few notable exceptions, like dynamically added users).

  (Yes, it's possible to make things in /etc be symlinks to read-write files, if necesarry. But it's frowned upon for good reasons.)

  If you do need to test something and don't want to deal with the trouble of packaging it just to test if it's even a good idea to spend more time with it, there's [incus](https://linuxcontainers.org/incus/docs/main/tutorial/first_steps/#launch-and-inspect-instances), available on nixos via `virtualisation.incus.enable = true; networking.firewall.trustedInterfaces = [ "incusbr*" ];`

# Roles vs modules and option priorities

In ansible you call a role with arguments, which then executes a bunch of tasks

```yaml
---
- name: install and configure server
  hosts:
    - my-server
  roles:
    - role: mgit_at.roles.base
      base_ssh_permit_root_login: "no"
```

This would roughly translate 1:1 to this in nixos:

```nix
{
  imports = [
    # returns config
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
