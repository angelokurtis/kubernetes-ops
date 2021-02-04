resource "helm_release" "tyk_mongo" {
  name = "tyk-mongo"
  chart = "https://charts.bitnami.com/bitnami/mongodb-10.6.1.tgz"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 120

  values = [
    yamlencode({
      auth = {
        rootPassword = var.mongodb_pass
      }
    })
  ]
}