#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "$(readlink -f "$0")")"
BASE=$(git rev-parse --show-toplevel)

incus exec bazelisk -- su test -l -c "USE_SHELL=1 bazelisk-env"
