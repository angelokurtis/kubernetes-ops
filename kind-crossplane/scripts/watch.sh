#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/resources.sh"
joined_resources="$(join_resources)"

set -x
watch kubectl get --all-namespaces "${joined_resources}"
