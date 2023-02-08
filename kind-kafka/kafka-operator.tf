locals {
  kafka_operator = { watchAnyNamespace = true }
}

resource "kubernetes_namespace_v1" "kafka_operator" {
  metadata { name = "kafka-operator" }
}
