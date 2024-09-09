#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "$(readlink -f "$0")")"
BASE=$(git rev-parse --show-toplevel)

incus launch images:nixos/unstable bazelisk -c security.nesting=true
incus config device add bazelisk nixos-common disk "source=$BASE" "path=/etc/nixos"
sleep 10s # allow it some time to boot
incus exec bazelisk -- nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git --command git config --global --add safe.directory /etc/nixos
incus exec bazelisk -- nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git --command git config --global --add safe.directory /etc/nixos/.git
incus exec bazelisk -- nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git --command nixos-rebuild switch --flake /etc/nixos#bazelisk || true
bash reset.sh
incus restart bazelisk
