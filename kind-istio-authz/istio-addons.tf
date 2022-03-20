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

