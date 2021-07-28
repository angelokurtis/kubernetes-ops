resource "helm_release" "sealed_secrets" {
  name = "sealed-secrets"
  namespace = kubernetes_namespace.encryption.metadata[0].name

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart = "sealed-secrets"
  version = "1.16.1"

  values = [
    yamlencode({
      commandArgs: [ "--key-renew-period=10m" ]
      secretName: kubernetes_secret.sealed_secrets_key.metadata[0].name
    })
  ]
}

resource "kubernetes_secret" "sealed_secrets_key" {
  metadata {
    name = "sealed-secrets-key"
    namespace = kubernetes_namespace.encryption.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = file(var.crt)
    "tls.key" = file(var.key)
  }
}

resource "kubernetes_namespace" "encryption" {
  metadata { name = "encryption" }
}
