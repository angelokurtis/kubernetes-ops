resource "helm_release" "rabbitmq" {
  name = "rabbitmq"
  namespace = kubernetes_namespace.queue.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "rabbitmq"
  version = "8.22.0"

  set {
    name = "auth.password"
    value = random_password.rabbitmq["password"].result
  }

  set {
    name = "auth.erlangCookie"
    value = random_password.rabbitmq["erlangCookie"].result
  }
}

resource "random_password" "rabbitmq" {
  for_each = toset(["password", "erlangCookie"])
  keepers = { database = each.key }
  length = 16
  special = false
}
