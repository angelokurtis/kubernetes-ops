locals {
  kafka_ui = {
    ingress = {
      enabled          = true,
      host             = "kafka.${local.cluster_host}",
      path             = "/"
      ingressClassName = "haproxy"
    }
    envs = {
      config = {
        KAFKA_CLUSTERS_0_NAME             = "single"
        KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS = "single-kafka-bootstrap.${kubernetes_namespace_v1.kafka.metadata[0].name}.svc:9092"
      }
    }
    image = {
      repository = "provectuslabs/kafka-ui"
      tag        = "027d9b4653e2f3ea13d4de6a0b2bd568106ffb40"
    }
  }
}

resource "kubernetes_namespace_v1" "kafka_ui" {
  metadata { name = "kafka-ui" }
}
