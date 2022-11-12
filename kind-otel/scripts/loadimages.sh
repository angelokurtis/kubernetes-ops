#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull --platform linux/amd64 $t)
  fi
  (set -x; kind load docker-image --name otel $t --nodes otel-worker)
}

loadImage docker.io/bitnami/kubectl:1.24
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
loadImage ghcr.io/fluxcd/helm-controller:v0.26.0
loadImage ghcr.io/fluxcd/kustomize-controller:v0.30.0
loadImage ghcr.io/fluxcd/source-controller:v0.31.0
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:v0.63.1
loadImage grafana/grafana:9.2.4
loadImage jaegertracing/all-in-one:1.39.0
loadImage jimmidyson/configmap-reload:v0.8.0
loadImage otel/opentelemetry-collector-contrib:0.64.1
loadImage quay.io/jcmoraisjr/haproxy-ingress:v0.13.9
loadImage quay.io/jetstack/cert-manager-cainjector:v1.10.0
loadImage quay.io/jetstack/cert-manager-controller:v1.10.0
loadImage quay.io/jetstack/cert-manager-webhook:v1.10.0
loadImage quay.io/prometheus/prometheus:v2.40.1
