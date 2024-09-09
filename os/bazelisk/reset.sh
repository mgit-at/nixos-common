#!/bin/bash

set -euxo pipefail

if [ ! -e /tmp/mgit ]; then
  git clone git@ci.mgit.at:mgit/mgit /tmp/mgit
fi
incus exec bazelisk -- rm -rf /home/test/mgit
incus exec bazelisk -- rm -rf /home/test/.cache
incus file push /tmp/mgit bazelisk/home/test -r
