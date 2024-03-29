locals {
  helm_repositories = {
    ingress-nginx = { repository = "https://kubernetes.github.io/ingress-nginx" }
    jaegertracing = { repository = "https://jaegertracing.github.io/helm-charts" }
    jetstack      = { repository = "https://charts.jetstack.io" }
  }
}

resource "kubectl_manifest" "helm_repository" {
  for_each = local.helm_repositories

  server_side_apply = true
  yaml_body         = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ${each.key}
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  timeout: ${local.fluxcd.default_timeout}
  url: ${each.value.repository}
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
