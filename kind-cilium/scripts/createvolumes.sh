#!/bin/bash

set -e

# Total of worker nodes
worker_nodes=3

# Create Docker volumes
(set -x; docker volume create --name cilium-control-plane)
for ((i=1; i<=worker_nodes; i++)); do
  if [ $i -eq 1 ]; then
    volume_name="cilium-worker"
  else
    volume_name="cilium-worker$i"
  fi
  (set -x; docker volume create --name "$volume_name")
done
