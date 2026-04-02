#!/usr/bin/env bash

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

# helper to join
join_resources() {
  IFS=,; echo "${resources[*]}"
}
