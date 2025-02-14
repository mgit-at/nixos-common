#!/usr/bin/env ysh

set -euo pipefail

setglobal ENV.PATH = "@path@"

setglobal ENV.MAILCOW_DIR = "/srv/mailcow"

die() {
  echo "ERROR: $*" >&2
  exit 2
}

id="$(id -u)"
if test "$id" -gt 0 {
  die "must be root"
}

if ! test -e "$MAILCOW_DIR" {
  git clone https://github.com/mailcow/mailcow-dockerized "$MAILCOW_DIR"
}

pushd "$MAILCOW_DIR"

var basename = "$(basename "$0")"
if (basename === "mailcow-shell") {
  echo "opening shell..."
  exec $SHELL
  exit $?
}

if test ! -e mailcow.conf {
  ./generate_config.sh
}

var settings
cat /etc/mailcow.json | json read (&settings)
for i, k, v in (settings) {
  initool set mailcow.conf "" "$k" "$v" > /tmp/mailcow.conf
  diff -u mailcow.conf /tmp/mailcow.conf || true
  mv /tmp/mailcow.conf mailcow.conf
}

./update.sh
