resource "helm_release" "rabbit" {
  name = "rabbitmq"
  chart = "https://charts.bitnami.com/bitnami/rabbitmq-8.13.1.tgz"
  namespace = kubernetes_namespace.horusec.metadata[0].name

  set {
    name = "auth.password"
    value = "1f17949a"
  }

  set {
    name = "auth.erlangCookie"
    value = "93c7308ffc78e6916eec"
  }
}

resource "kubernetes_secret" "broker_username" {
  metadata {
    name = "broker-username"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "broker-username" = "user"
  }
}
