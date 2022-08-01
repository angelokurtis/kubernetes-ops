resource "kubectl_manifest" "traefik_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: traefik
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://helm.traefik.io/traefik
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "prometheus_community_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: prometheus-community
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://prometheus-community.github.io/helm-charts
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
