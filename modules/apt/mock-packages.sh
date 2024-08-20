#!@bash@/bin/bash

set -euo pipefail

write_info()  {
echo "
Package: $1
Status: install ok installed
Priority: optional
Maintainer: Dummy <dummy@localhost>
Architecture: all
Version: 0
Description: Dummy-package to resolve dependencies
"
}

mock() {
  if ! dpkg --get-selections | grep "^$1\t" >/dev/null 2>/dev/null; then
    mkdir -p /var/lib/dpkg/info
    write_info "$1" >> /var/lib/dpkg/status
    touch "/var/lib/dpkg/info/$1.list"
    touch "/var/lib/dpkg/info/$1.md5sums"
  fi
}

for pkg in "$@"; do
  mock "$pkg"
done
