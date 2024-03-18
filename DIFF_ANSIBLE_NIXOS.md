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

# Why nixos and not ansible?

- "roles" (modules) and packages are a shared community-effort, instead of a single-person effort

  In NixOS all modules and packages reside in nixpkgs and anyone can contribute anywhere, with certain quality expectations by default. No longer do you need to search github for the perfect nginx role, when you can just use search.nixos.org to get the options for [`services.nginx`](https://search.nixos.org/options#?channel=unstable&from=0&size=50&sort=alpha_asc&type=packages&query=services.nginx.virtualHosts)

- nixos has a "no pfusch" attitude

  You can't just do a quick hack that's not going to be documented in the repo.
  You will at the very least need to edit the configuration and deploy, as /etc is fully read-only.

  (Yes, it's possible to make things in /etc be symlinks to read-write files, if necesarry. But it's frowned upon for good reasons.)

- ansible assumes a pristine base state.

  Installed something for testing but forgot to remove it, but only on some hosts? Prepare for surprise.

  Other hosting provider shipping differente defaults for the same distro, that you need to figure out and potentially clean up or even re-install the os? Not with nixos.

- nixos has profiles for common environments, that get maintained for you

  If you have, for example, a qemu guest you can include `imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];` and you will automatically profit from improvments done to the qemu profile, instead of having to re-install or manually "backport" the changes to the defaults that were done.

  Otherwise ocasionally running `nixos-generate-config` will also give you an updated hardware configuration, with any new features.

- In nixos, if it's gone from the configuration it's gone from the os.

  No longer do you need to write cleanup routines or re-install.

  Notable exception: State in /var/lib, as that is managed by the application and not the os.

- Major version upgrades are possible without having to pray that the server will come online once again

  You can just use `nixos-rebuild boot ...` to deploy a configuration on reboot and have the server boot the config.

- You can test if your module/deployment works, with minimal effort.

  Look in this repo's `test/` folder for examples. If you aren't convinced take a look at nixpkgs's `nixos/tests/`

- `ansible is a hack` - gebi

# Pitfalls of nixos

- quickly testing something that hasn't been packaged yet is usually not (easily) possible

  You can run other operating systems as full-os containers with minimal overhead using [incus](https://linuxcontainers.org/incus/docs/main/tutorial/first_steps/#launch-and-inspect-instances), available on nixos via
  ```nix
  {
    virtualisation.incus.enable = true;
    networking.firewall.trustedInterfaces = [ "incusbr*" ];
  }
  ```

  If you just need to run binaries that require a dynamic linker and some packages, take a look at [`programs.nix-ld`](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=programs.nix-ld)
