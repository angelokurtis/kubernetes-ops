locals {
  service_accounts = [
    "otelcol-traces",
    "otelcol-traces-backend",
    "otelcol-metrics",
  ]
}

resource "kubernetes_service_account_v1" "otel_collectors" {
  for_each = toset(local.service_accounts)
  metadata {
    name      = each.key
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "otel_collector" {
  metadata { name = "otel-collector" }
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "otel_collector" {
  for_each = toset(local.service_accounts)
  metadata { name = each.key }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "otel-collector"
  }
  subject {
    kind      = "ServiceAccount"
    name      = each.key
    namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name
  }
}
