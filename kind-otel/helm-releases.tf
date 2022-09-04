locals {
  helm_releases = {
    cert-manager = {
      namespace       = kubernetes_namespace_v1.cert_manager.metadata[0].name,
      helm_repository = "jetstack",
      values          = local.cert_manager,
    }
    jaeger = {
      namespace      = kubernetes_namespace_v1.jaeger.metadata[0].name,
      chart          = "charts/jaeger",
      git_repository = "jaeger-helm-charts",
      values         = local.jaeger,
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
      values          = local.nginx,
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
