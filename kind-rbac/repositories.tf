resource "kubectl_manifest" "ingress_nginx_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ingress-nginx
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://kubernetes.github.io/ingress-nginx
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "fairwinds_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: fairwinds
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://charts.fairwinds.com/stable
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
