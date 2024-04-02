# Hcloud

- Create new VM:
  - location: falkenstein
  - image: ubuntu 22.04
  - type: shared x86
    - use smallest node type (first in list)
  - networking: v4 + v6
  - ssh keys: pick your own
  - name: nixos-image
- copy ipv4
- run:

```
nix run github:nix-community/nixos-anywhere -- --no-reboot --flake .#hcloud root@IPV4
```

- wait until finished
- shutdown machine
- create snapshot, nixos-base-image
- delete machine
