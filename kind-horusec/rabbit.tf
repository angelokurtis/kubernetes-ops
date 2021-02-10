resource "helm_release" "rabbit" {
  name = "rabbitmq"
  chart = "https://charts.bitnami.com/bitnami/rabbitmq-8.9.2.tgz"
  namespace = kubernetes_namespace.queue.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "service" = { "labels" = { "app" = "rabbitmq" } }
      "podLabels" = { "app" = "rabbitmq" }
    })
  ]
}
