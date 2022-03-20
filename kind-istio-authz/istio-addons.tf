resource "kubectl_manifest" "addons_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${local.istio.addons.gateway}
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  selector:
    istio: "ingressgateway"
  servers:
    - hosts: [${join(", ", local.istio.addons.hosts)}]
      port:
        name: http
        number: 80
        protocol: HTTP
YAML

  depends_on = [
    kubectl_manifest.istio,
    kubectl_manifest.kiali_helm_release
  ]
}

resource "kubectl_manifest" "kiali_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kiali-server
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: kiali-server
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: kiali
        namespace: default
  values:
    auth:
      strategy: "anonymous"
    deployment:
      accessible_namespaces:
      - "**"
      ingress_enabled: false
      pod_annotations:
        "sidecar.istio.io/inject": "false"
    external_services:
      prometheus:
        url: http://prometheus.${local.istio.namespace}:9090
    login_token:
      signing_key: "${random_password.kiali_signing_key.result}"
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.kiali_helm_repository
  ]
}

resource "kubectl_manifest" "kiali_ui_virtual_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali-ui
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  gateways:
    - ${local.istio.addons.gateway}
  hosts:
    - ${local.kiali.host}
  http:
    - route:
        - destination:
            host: "kiali.${kubernetes_namespace.istio.metadata[0].name}.svc.cluster.local"
            port:
              number: 20001
YAML

  depends_on = [
    kubectl_manifest.istio,
    kubectl_manifest.kiali_helm_release
  ]
}

resource "random_password" "kiali_signing_key" {
  length = 16
}


resource "kubectl_manifest" "prometheus_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: prometheus
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: prometheus
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: prometheus
        namespace: default
  values:
    alertmanager:
      enabled: false
    kubeStateMetrics:
      enabled: false
    nodeExporter:
      enabled: false
    pushgateway:
      enabled: false
    server:
      fullnameOverride: "prometheus"
      global:
        scrape_interval: "15s"
      persistentVolume:
        enabled: false
      podAnnotations:
        "sidecar.istio.io/inject": "false"
      readinessProbeInitialDelay: 0
      service:
        servicePort: 9090
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.prometheus_helm_repository
  ]
}
