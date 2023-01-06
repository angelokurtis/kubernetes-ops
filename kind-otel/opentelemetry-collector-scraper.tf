resource "kubectl_manifest" "opentelemetry_collector_scraper" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "scraper", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config = file("${path.cwd}/opentelemetry-collector-scraper.yaml")
      mode   = "daemonset"
      env    = [
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}:80"
        },
        {
          name      = "KUBE_NODE_NAME",
          valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } }
        },
      ]
      podAnnotations = { "prometheus.io/scrape" = "true", "prometheus.io/port" = "8888" }
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}

resource "kubernetes_cluster_role_binding_v1" "pods_reader" {
  metadata {
    name = "${kubectl_manifest.opentelemetry_collector_scraper.name}-collector-pods-reader"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.pods_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubectl_manifest.opentelemetry_collector_scraper.name}-collector"
    namespace = kubectl_manifest.opentelemetry_collector_scraper.namespace
  }
}

resource "kubernetes_cluster_role_v1" "pods_reader" {
  metadata { name = "pods-reader" }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}
