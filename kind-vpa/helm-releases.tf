locals {
  helm_releases = {
    cert-manager = {
      namespace       = kubernetes_namespace_v1.cert_manager.metadata[0].name,
      helm_repository = "jetstack",
      values          = local.cert_manager,
    }
    goldilocks = {
      namespace       = kubernetes_namespace_v1.goldilocks.metadata[0].name,
      helm_repository = "fairwinds-stable",
      dependsOn       = [{ name = "nginx", namespace = kubernetes_namespace_v1.nginx.metadata[0].name }],
      values          = local.goldilocks,
    }
    grafana = {
      namespace       = kubernetes_namespace_v1.grafana.metadata[0].name,
      helm_repository = "grafana",
      dependsOn       = [{ name = "nginx", namespace = kubernetes_namespace_v1.nginx.metadata[0].name }],
      values          = local.grafana,
    }
    jaeger = {
      namespace       = kubernetes_namespace_v1.jaeger.metadata[0].name,
      helm_repository = "jaegertracing",
      dependsOn       = [{ name = "nginx", namespace = kubernetes_namespace_v1.nginx.metadata[0].name }],
      values          = local.jaeger,
    }
    metrics-server = {
      namespace       = kubernetes_namespace_v1.metrics_server.metadata[0].name,
      helm_repository = "metrics-server",
      values          = local.metrics_server,
    }
    nginx = {
      namespace       = kubernetes_namespace_v1.nginx.metadata[0].name,
      chart           = "ingress-nginx",
      helm_repository = "ingress-nginx",
      values          = local.nginx,
    }
    opentelemetry-operator = {
      namespace       = kubernetes_namespace_v1.opentelemetry.metadata[0].name,
      helm_repository = "opentelemetry",
      dependsOn       = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }],
      values          = local.opentelemetry_operator,
    }
    prometheus = {
      namespace       = kubernetes_namespace_v1.prometheus.metadata[0].name,
      helm_repository = "prometheus-community",
      dependsOn       = [{ name = "nginx", namespace = kubernetes_namespace_v1.nginx.metadata[0].name }],
      values          = local.prometheus,
    }
    vertical-pod-autoscaler = {
      namespace       = kubernetes_namespace_v1.vertical_pod_autoscaler.metadata[0].name,
      helm_repository = "cowboysysop",
      values          = local.vertical_pod_autoscaler,
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
