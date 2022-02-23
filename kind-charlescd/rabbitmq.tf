resource "kubectl_manifest" "rabbitmq_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: rabbitmq
  namespace: ${kubernetes_namespace.rabbitmq.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  chart:
    spec:
      chart: rabbitmq
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: default
  values:
    auth:
      password: "${random_password.rabbitmq["password"].result}"
      erlangCookie: "${random_password.rabbitmq["erlangCookie"].result}"
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "random_password" "rabbitmq" {
  for_each = toset(["password", "erlangCookie"])
  keepers  = { database = each.key }
  length   = 16
}

resource "kubernetes_namespace" "rabbitmq" {
  metadata { name = "rabbitmq" }
}
