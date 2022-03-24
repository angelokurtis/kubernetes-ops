resource "kubectl_manifest" "football_bets_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: football-bets
  namespace: ${kubernetes_namespace.demo.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: chart/football-bets
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: football-bets
        namespace: default
  values:
    bets:
      annotations:
        "sidecar.istio.io/userVolume": ${jsonencode([{
            name      = "wasm"
            configMap = { name = kubernetes_config_map_v1.hello_wasm.metadata[0].name }
        }])}
        "sidecar.istio.io/userVolumeMount": ${jsonencode([{name = "wasm", mountPath = "/var/local/wasm"}])}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.football_bets_git_repository,
    kubernetes_job_v1.wait_istio,
  ]
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name   = "demo"
    labels = { "istio.io/rev" = replace(local.istio.version, ".", "-") }
  }
}

resource "kubernetes_config_map_v1" "hello_wasm" {
  metadata {
    name      = "hello-wasm"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  binary_data = {
    "hello.wasm" = filebase64(pathexpand("~/.wasme/store/d3cff1ecb7fbf00858fad4b8921e6cb9/filter.wasm"))
  }
}
