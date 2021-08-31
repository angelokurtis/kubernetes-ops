locals {
  sealed_secrets = {
    name = "sealed-secrets"
    destination = {
      namespace = kubernetes_namespace.encryption.metadata[0].name
      server = "https://kubernetes.default.svc"
    }
    source = {
      chart = "sealed-secrets"
      repoURL = "https://bitnami-labs.github.io/sealed-secrets"
      targetRevision = "1.16.1"
      helm = {
        values = yamlencode({ commandArgs = ["--update-status"] })
      }
    }
  }
}

resource "kubernetes_secret" "sealed_secrets_key" {
  metadata {
    name = "sealed-secrets-key"
    namespace = kubernetes_namespace.encryption.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = file(var.public_key)
    "tls.key" = file(var.private_key)
  }
}

resource "kubernetes_namespace" "encryption" {
  metadata { name = "encryption" }
}
