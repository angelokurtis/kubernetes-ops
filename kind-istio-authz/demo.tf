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
