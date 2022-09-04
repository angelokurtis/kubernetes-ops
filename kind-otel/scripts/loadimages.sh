#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull $t)
  fi
  (set -x; kind load docker-image --name otel $t)
}

loadImage quay.io/jetstack/cert-manager-controller:v1.9.1
loadImage quay.io/jetstack/cert-manager-cainjector:v1.9.1
loadImage quay.io/jetstack/cert-manager-webhook:v1.9.1
loadImage docker.io/bitnami/kubectl:1.23
loadImage ghcr.io/fluxcd/helm-controller:v0.22.2
loadImage ghcr.io/fluxcd/source-controller:v0.26.1
loadImage jaegertracing/all-in-one:1.37.0
loadImage registry.k8s.io/ingress-nginx/controller:v1.3.0@sha256:d1707ca76d3b044ab8a28277a2466a02100ee9f58a86af1535a3edf9323ea1b5
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:0.58.0
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
