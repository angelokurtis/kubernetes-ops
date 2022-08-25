locals {
  helm_releases = {
    cert-manager = local.cert-manager
    jaeger       = local.jaeger
    nginx        = local.nginx
  }
}

resource "kubectl_manifest" "helm_release" {
  for_each = local.helm_releases

  server_side_apply = true
  yaml_body         = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: ${each.key}
  namespace: ${each.value.namespace}
spec:
  chart:
    spec:
      chart: ${each.value.chart}
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: ${each.value.helm_repository.name}
        namespace: ${each.value.helm_repository.namespace}
      version: "${try(each.value.version, "*")}"
  dependsOn: ${jsonencode(try(each.value.dependsOn, []))}
  interval: ${local.fluxcd.default_interval}
  values: ${jsonencode(try(each.value.values, {}))}
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
