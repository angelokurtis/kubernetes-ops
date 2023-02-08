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
  }
}

resource "kubernetes_namespace_v1" "kafka_ui" {
  metadata { name = "kafka-ui" }
}
