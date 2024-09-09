#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "$(readlink -f "$0")")"
BASE=$(git rev-parse --show-toplevel)

incus exec bazelisk -- nixos-rebuild switch
incus restart bazelisk # kill old bazel processes
sleep 5s # allow it some time to boot
incus exec bazelisk -- sh -c "cd /home/test/mgit && su test -c 'bazelisk-env build //... --sandbox_debug --verbose_failures --keep_going'"
