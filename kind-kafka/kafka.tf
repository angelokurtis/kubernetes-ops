locals {
  kafka = {
    topics = ["mytopic"]
  }
}

resource "kubectl_manifest" "kafka" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata   = { name = "single", namespace = kubernetes_namespace_v1.kafka.metadata[0].name }
    spec       = {
      entityOperator = { topicOperator = {}, userOperator = {} }
      kafka          = {
        config = {
          "default.replication.factor"               = 1
          "inter.broker.protocol.version"            = "3.3"
          "min.insync.replicas"                      = 1
          "offsets.topic.replication.factor"         = 1
          "transaction.state.log.min.isr"            = 1
          "transaction.state.log.replication.factor" = 1
          "auto.create.topics.enable"                = "false"
        }
        listeners = [
          { name = "plain", port = 9092, tls = false, type = "internal" },
          { name = "tls", port = 9093, tls = true, type = "internal" },
        ]
        replicas = 1
        storage  = {
          type    = "jbod"
          volumes = [{ deleteClaim = false, id = 0, size = "100Gi", type = "persistent-claim" }]
        }
        version = "3.3.2"
      }
      zookeeper = {
        replicas = 1
        storage  = { deleteClaim = false, size = "100Gi", type = "persistent-claim" }
      }
    }
  })

  depends_on = [kubernetes_job_v1.wait_helm_release["strimzi-kafka-operator"]]
}

resource "kubectl_manifest" "kafka_topic" {
  for_each = toset(local.kafka.topics)

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata   = {
      labels    = { "strimzi.io/cluster" = kubectl_manifest.kafka.name }
      name      = each.key
      namespace = kubernetes_namespace_v1.kafka.metadata[0].name
    }
    spec = {
      config = {
        "retention.ms"  = 7200000    # 2 hours
        "segment.bytes" = 1073741824 # 1 GiB
      }
      partitions = 1
      replicas   = 1
    }
  })

  depends_on = [kubectl_manifest.kafka]
}

resource "kubernetes_namespace_v1" "kafka" {
  metadata { name = "kafka" }
}
