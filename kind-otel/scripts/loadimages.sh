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
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.13.0
loadImage ghcr.io/fluxcd/helm-controller:v0.28.1
loadImage ghcr.io/fluxcd/kustomize-controller:v0.32.0
loadImage ghcr.io/fluxcd/source-controller:v0.33.0
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:v0.67.0
loadImage grafana/grafana:9.3.2
loadImage jaegertracing/all-in-one:1.41.0
loadImage jimmidyson/configmap-reload:v0.8.0
loadImage kurtis/bets:1.0.0-java-spring
loadImage kurtis/championships:1.0.0-java-spring
loadImage kurtis/matches:1.0.0-java-spring
loadImage kurtis/teams:1.0.0-java-spring
loadImage otel/opentelemetry-collector-contrib:0.69.0
loadImage quay.io/jetstack/cert-manager-cainjector:v1.11.0
loadImage quay.io/jetstack/cert-manager-controller:v1.11.0
loadImage quay.io/jetstack/cert-manager-webhook:v1.11.0
loadImage quay.io/prometheus/prometheus:v2.41.0
loadImage registry.k8s.io/ingress-nginx/controller:v1.5.1@sha256:4ba73c697770664c1e00e9f968de14e08f606ff961c76e5d7033a4a9c593c629
