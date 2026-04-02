#!/usr/bin/env bash

set -euo pipefail

# Usage: script.sh <workspace-resource/name> [namespace]
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <workspace-resource/name> [namespace]"
  exit 1
fi

FULL_NAME="$1"
NAMESPACE="${2:-}"

# Validate allowed resources and extract name
if [[ "$FULL_NAME" =~ ^(workspace|workspaces)\.opentofu\.upbound\.io/([^/]+)$ || \
      "$FULL_NAME" =~ ^(workspace|workspaces)\.opentofu\.m\.upbound\.io/([^/]+)$ ]]; then
  WORKSPACE_NAME="${BASH_REMATCH[2]}"
else
  echo "Invalid resource. Only allowed:"
  echo "  - workspaces.opentofu.upbound.io/<name>"
  echo "  - workspaces.opentofu.m.upbound.io/<name>"
  echo "  - workspace.opentofu.upbound.io/<name>"
  echo "  - workspace.opentofu.m.upbound.io/<name>"
  exit 1
fi

# Optional namespace args
NS_ARGS=()
if [[ -n "$NAMESPACE" ]]; then
  NS_ARGS=(-n "$NAMESPACE")
fi

# Get workspace UID
WORKSPACE_UID=$(kubectl get "$FULL_NAME" "${NS_ARGS[@]}" -o jsonpath='{.metadata.uid}')

if [[ -z "$WORKSPACE_UID" ]]; then
  echo "Failed to retrieve workspace UID"
  exit 1
fi

# Find pod
POD_NAME=$(kubectl get pods "${NS_ARGS[@]}" -l pkg.crossplane.io/provider=crossplane-provider-opentofu -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$POD_NAME" ]]; then
  echo "No matching pod found"
  exit 1
fi

REMOTE_PATH="/tofu/${WORKSPACE_UID}"
LOCAL_DIR="./workspaces/${WORKSPACE_NAME}/${WORKSPACE_UID}"

mkdir -p "$LOCAL_DIR"

# Copy using tar to preserve symlinks
kubectl exec "${NS_ARGS[@]}" "$POD_NAME" -- \
  tar cf - "$REMOTE_PATH" \
  | tar xf - -C "$LOCAL_DIR" --strip-components=2

echo "Copied ${REMOTE_PATH} from pod ${POD_NAME}${NAMESPACE:+ (ns: $NAMESPACE)} to ${LOCAL_DIR}"
