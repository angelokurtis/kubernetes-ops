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
loadImage kurtis/bets:1.0.0-java-spring
loadImage kurtis/championships:1.0.0-java-spring
loadImage kurtis/matches:1.0.0-java-spring
loadImage kurtis/teams:1.0.0-java-spring
loadImage ghcr.io/fluxcd/helm-controller:v0.24.0
loadImage ghcr.io/fluxcd/kustomize-controller:v0.28.0
loadImage ghcr.io/fluxcd/source-controller:v0.29.0
loadImage us-docker.pkg.dev/fairwinds-ops/oss/goldilocks:v4.4.0
loadImage grafana/grafana:9.1.6
loadImage jaegertracing/all-in-one:1.38.0
loadImage k8s.gcr.io/metrics-server/metrics-server:v0.6.1
loadImage registry.k8s.io/ingress-nginx/controller:v1.3.1@sha256:54f7fe2c6c5a9db9a0ebf1131797109bb7a4d91f56b9b362bde2abd237dd1974
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:0.60.0
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
loadImage kurtis/otel-collector:v1.0.8
loadImage registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.5.0
loadImage quay.io/prometheus/node-exporter:v1.3.1
loadImage jimmidyson/configmap-reload:v0.7.1
loadImage quay.io/prometheus/prometheus:v2.38.0
loadImage k8s.gcr.io/autoscaling/vpa-recommender:0.11.0
