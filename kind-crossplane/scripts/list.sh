#!/usr/bin/env bash

set -euo pipefail

resources=(
  # Namespaced resources
  clusterproviderconfigs.opentofu.m.upbound.io
  providerconfigs.opentofu.m.upbound.io
  providerconfigusages.opentofu.m.upbound.io
  workspaces.opentofu.m.upbound.io

  # Cluster-scoped resources
  providerconfigs.opentofu.upbound.io
  providerconfigusages.opentofu.upbound.io
  workspaces.opentofu.upbound.io
)

# Join resources into a comma-separated string
joined_resources="$(IFS=,; echo "${resources[*]}")"

set -x
kubectl get --all-namespaces "${joined_resources}"
