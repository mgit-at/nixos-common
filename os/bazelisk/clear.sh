#!/bin/bash

set -euxo pipefail

incus exec bazelisk -- rm -rf /home/test/.cache/bazel
