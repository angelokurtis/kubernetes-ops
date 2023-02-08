#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull --platform linux/amd64 $t)
  fi
  (set -x; kind load docker-image --name otel $t --nodes otel-worker)
}

loadImage docker.io/bitnami/kubectl:1.25
loadImage docker.io/provectuslabs/kafka-ui:v0.4.0
loadImage ghcr.io/fluxcd/helm-controller:v0.29.0
loadImage ghcr.io/fluxcd/kustomize-controller:v0.33.0
loadImage ghcr.io/fluxcd/source-controller:v0.34.0
loadImage jimmidyson/configmap-reload:v0.8.0
loadImage prom/pushgateway:v1.5.1
loadImage quay.io/jcmoraisjr/haproxy-ingress:v0.14.0
loadImage quay.io/prometheus/node-exporter:v1.5.0
loadImage quay.io/prometheus/prometheus:v2.40.7
loadImage quay.io/strimzi/kafka:0.33.1-kafka-3.3.2
loadImage quay.io/strimzi/operator:0.33.1
loadImage registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.7.0
