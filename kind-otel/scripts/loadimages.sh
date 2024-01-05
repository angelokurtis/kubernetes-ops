#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull --platform linux/amd64 $t)
  fi
  (set -x; kind load docker-image --name otel $t --nodes otel-worker)
}

loadImage docker.io/bitnami/kubectl:1.27
loadImage docker.io/grafana/grafana:10.2.3
loadImage ghcr.io/fluxcd/helm-controller:v0.37.2
loadImage ghcr.io/fluxcd/image-automation-controller:v0.37.0
loadImage ghcr.io/fluxcd/image-reflector-controller:v0.31.1
loadImage ghcr.io/fluxcd/kustomize-controller:v1.2.1
loadImage ghcr.io/fluxcd/notification-controller:v1.2.3
loadImage ghcr.io/fluxcd/source-controller:v1.2.3
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:v0.90.0
loadImage ghcr.io/weaveworks/wego-app:v0.38.0
loadImage jaegertracing/all-in-one:1.52.0
loadImage kurtis/bets:1.0.0-java-spring
loadImage kurtis/championships:1.0.0-java-spring
loadImage kurtis/matches:1.0.0-java-spring
loadImage kurtis/teams:1.0.0-java-spring
loadImage quay.io/brancz/kube-rbac-proxy:v0.15.0
loadImage quay.io/jetstack/cert-manager-cainjector:v1.13.3
loadImage quay.io/jetstack/cert-manager-controller:v1.13.3
loadImage quay.io/jetstack/cert-manager-webhook:v1.13.3
loadImage quay.io/prometheus-operator/prometheus-config-reloader:v0.70.0
loadImage quay.io/prometheus/prometheus:v2.48.1
loadImage registry.k8s.io/ingress-nginx/controller:v1.9.5@sha256:b3aba22b1da80e7acfc52b115cae1d4c687172cbf2b742d5b502419c25ff340e
