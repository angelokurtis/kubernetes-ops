resource "kubectl_manifest" "jetstack_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: jetstack
  namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://charts.jetstack.io
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "cert_manager_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cert-manager
  namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  chart:
    spec:
      chart: cert-manager
      sourceRef:
        kind: HelmRepository
        name: jetstack
  values:
    installCRDs: true
    prometheus:
      enabled: false
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jetstack_helm_repository
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = var.cert_manager_namespace }
}
