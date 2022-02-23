resource "kubectl_manifest" "redis_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: redis
  namespace: ${kubernetes_namespace.redis.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  chart:
    spec:
      chart: redis
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: default
  values:
    nameOverride: redis
    architecture: standalone
    auth:
      existingSecret: "${kubernetes_secret.redis.metadata[0].name}"
      existingSecretPasswordKey: password
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "random_password" "redis" {
  special = false
  length  = 16
}

resource "kubernetes_secret" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }
  data = {
    password = random_password.redis.result
  }
}

resource "kubernetes_namespace" "redis" {
  metadata { name = var.redis_namespace }
}
