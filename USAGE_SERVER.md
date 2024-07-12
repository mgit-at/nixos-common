# Using mgit nixos-common

Note: This is mostly meant for employes of mgit GmbH, but you can feel free to use this for your personal cloud aswell.

Note: When told to copy a file, its from the `template/` directory of this repo.

# Creating a new repo from scratch

You can either copy all files from `template/` or use `nix flake new my-repo -t github:mgit-at/nixos-common#default`

# Installing a new machine: Native NixOS

## Creating the necesarry files

- Hetzner Cloud: Copy nixos/hosts/example-hcloud, adjust stateVersion and the IPv6 address and hostname
- Physical machine:
  - Use NixOS ISO on machine beforehand to generate nixos hardware-configuration.nix using `nixos-generate-config`
  - Copy `nixos/hosts/example-physical` to `nixos/hosts/HOST`
  - Copy `/etc/nixos/hardware-configuration.nix` to `nixos/hosts/HOST/hardware-configuration.nix`
  - Strip filesystems section
  - Add disko disk configuration as `nixos/hosts/HOST/disko.nix`. See [examples](https://github.com/nix-community/disko/tree/master/example).
  - Adjust disko devices.

Copy playbooks/example-nixos-native.yml, adjust the host.
You can also use a group.
Just make sure you have no unrelated hosts mixed together.

## Doing the deployment

Create the machine
- Hetzner Cloud:
  - Create the machine on Hetzner Cloud.
    - Use ubuntu - version doesn't matter - as the os.
    - Add your own ssh key
  - Add the machine to ansible
    - If the machine is part of a project that is indexed through dynamic inventory, simply reference it in the ansible playbook
    - Otherwise add the host with it's IPv4 under inventory/hosts.ini `my-host ansible_host=1.2.3.4`

Deploy the machine
- Run `NIXOS_ANYWHERE=1 ansible-playbook playbooks/PLAYBOOK.yml`
  - This will start installing the machine using nixos-anywhere
  - This will create, among others, `playbooks/_nix_ansible_/your-host.sh`, which can be used for subsequent deploys - if only the nixos side of things was changed - or debugging of issues with nix files through interactive output.
- For subsequent deploys via ansible simply omit `NIXOS_ANYWHERE=1`

# Installing nix unify on a machine

## Creating the necesarry files

Copy `nixos/hosts/example-unify`.
Adjust the network details if you plan to use nix-unify networkd sharing, otherwise remove them and the `shareNetworkd.enable = true;` option.

Adjust the firewall if you plan to use nftables sharing, or remove `networking.firewall` and `shareNftables.enable = true;`.

Copy `playbooks/example-nix-unify.yml`, adjust the host.
You can also use a group.
Just make sure you have no unrelated hosts mixed together.

## Doing the deployment

Add the machine to ansible
- If the machine is part of a project that is indexed through dynamic inventory, simply reference it in the ansible playbook.
- Otherwise add the host with it's IPv4 under inventory/hosts.ini `my-host ansible_host=1.2.3.4`.

Deploy with `ansible-playbook playbooks/PLAYBOOK.yml`, without any extra flags.
- This will create, among others, `playbooks/_nix_ansible_/your-host.sh`, which can be used for subsequent deploys - if only the nixos side of things was changed - or debugging of issues with nix files through interactive output.
