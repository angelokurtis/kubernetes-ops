#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull $t)
  fi
  (set -x; kind load docker-image --name otel $t)
}

loadImage docker.io/bitnami/kubectl:1.23
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
loadImage ghcr.io/fluxcd/helm-controller:v0.25.0
loadImage ghcr.io/fluxcd/kustomize-controller:v0.29.0
loadImage ghcr.io/fluxcd/source-controller:v0.30.0
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:0.60.0
loadImage grafana/grafana:9.1.7
loadImage jaegertracing/all-in-one:1.38.1
loadImage jimmidyson/configmap-reload:v0.7.1
loadImage k8s.gcr.io/metrics-server/metrics-server:v0.6.1
loadImage kurtis/bets:1.0.0-java-spring
loadImage kurtis/championships:1.0.0-java-spring
loadImage kurtis/matches:1.0.0-java-spring
loadImage kurtis/otel-collector:v1.0.8
loadImage kurtis/teams:1.0.0-java-spring
loadImage quay.io/jetstack/cert-manager-cainjector:v1.9.1
loadImage quay.io/jetstack/cert-manager-controller:v1.9.1
loadImage quay.io/jetstack/cert-manager-webhook:v1.9.1
loadImage quay.io/prometheus/node-exporter:v1.3.1
loadImage quay.io/prometheus/prometheus:v2.39.1
loadImage registry.k8s.io/ingress-nginx/controller:v1.4.0@sha256:34ee929b111ffc7aa426ffd409af44da48e5a0eea1eb2207994d9e0c0882d143
loadImage registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20220916-gd32f8c343@sha256:39c5b2e3310dc4264d638ad28d9d1d96c4cbb2b2dcfb52368fe4e3c63f61e10f
loadImage registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.5.0
