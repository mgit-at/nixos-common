#!/usr/bin/env bash

set -euo pipefail

export PATH=@path@

MAILCOW_DIR="/srv/mailcow"

die() {
  echo "ERROR: $*" >&2
  exit 2
}

if [ "$(id -u)" -gt 0 ]; then
  die "must be root"
fi

if [ ! -e "$MAILCOW_DIR" ]; then
  git clone https://github.com/mailcow/mailcow-dockerized "$MAILCOW_DIR"
fi

pushd "$MAILCOW_DIR"

if [ "$(basename "$0")" = "mailcow-shell" ]; then
  echo "opening shell..."
  exec $SHELL
  exit $?
fi

if [ ! -e mailcow.conf ]; then
  ./generate_config.sh
fi

./update.sh
