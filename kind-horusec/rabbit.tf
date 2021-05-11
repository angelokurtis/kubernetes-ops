resource "helm_release" "rabbit" {
  name = "rabbitmq"
  chart = "https://charts.bitnami.com/bitnami/rabbitmq-8.13.1.tgz"
  namespace = kubernetes_namespace.horusec.metadata[0].name

  set {
    name = "auth.password"
    value = "qQAUEGhQ6R"
  }

  set {
    name = "auth.erlangCookie"
    value = "DX5NKjaLajEYC9t6hJujJa25PqpbFXF4"
  }
}
