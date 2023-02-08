locals {
  helm_releases = {
    kminion = {
      git_repository = "kminion"
      chart          = "charts/kminion"
      namespace      = kubernetes_namespace_v1.kminion.metadata[0].name,
      dependsOn      = [{ name = "strimzi-kafka-operator", namespace = kubernetes_namespace_v1.kafka_operator.metadata[0].name }],
      values         = local.kminion,
    }
    strimzi-kafka-operator = {
      helm_repository = "strimzi",
      namespace       = kubernetes_namespace_v1.kafka_operator.metadata[0].name,
      values          = local.kafka_operator,
    }
    kafka-ui = {
      git_repository = "kafka-ui"
      chart          = "charts/kafka-ui"
      namespace      = kubernetes_namespace_v1.kafka_ui.metadata[0].name,
      values         = local.kafka_ui,
    }
    haproxy = {
      namespace       = kubernetes_namespace_v1.haproxy.metadata[0].name,
      chart           = "haproxy-ingress",
      helm_repository = "haproxy-ingress",
      values          = local.haproxy,
    }
    prometheus = {
      namespace       = kubernetes_namespace_v1.prometheus.metadata[0].name,
      helm_repository = "prometheus-community",
      dependsOn       = [{ name = "haproxy", namespace = kubernetes_namespace_v1.haproxy.metadata[0].name }],
      values          = local.prometheus,
    }
    grafana = {
      namespace       = kubernetes_namespace_v1.grafana.metadata[0].name,
      helm_repository = "grafana",
      dependsOn       = [{ name = "haproxy", namespace = kubernetes_namespace_v1.haproxy.metadata[0].name }],
      values          = local.grafana,
    }
  }
}

resource "kubectl_manifest" "helm_release" {
  for_each = local.helm_releases

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "helm.toolkit.fluxcd.io/v2beta1"
    kind       = "HelmRelease"
    metadata   = { name = each.key, namespace = each.value.namespace }
    spec       = {
      chart = {
        spec = try(
          {
            chart             = try(each.value.chart, each.key)
            reconcileStrategy = "ChartVersion"
            version           = try(each.value.version, "*")
            sourceRef         = {
              kind      = "HelmRepository"
              name      = kubectl_manifest.helm_repository[each.value.helm_repository].name
              namespace = kubectl_manifest.helm_repository[each.value.helm_repository].namespace
            }
          },
          {
            chart             = try(each.value.chart, each.key)
            reconcileStrategy = "Revision"
            sourceRef         = {
              kind      = "GitRepository"
              name      = kubectl_manifest.git_repository[each.value.git_repository].name
              namespace = kubectl_manifest.git_repository[each.value.git_repository].namespace
            }
          }
        )
      }
      interval  = local.fluxcd.default_interval
      values    = try(each.value.values, {})
      dependsOn = try(each.value.dependsOn, [])
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
