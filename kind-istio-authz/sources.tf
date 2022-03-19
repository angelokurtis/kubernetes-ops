resource "kubectl_manifest" "bitnami_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: bitnami
  namespace: default
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://charts.bitnami.com/bitnami
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "istio_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: istio
  namespace: default
spec:
  ignore: |
    /*                                # exclude all
    !/manifests/charts/istio-operator # include deploy dir
  interval: ${local.fluxcd.default_interval}
  ref:
    semver: "~${local.istio.version}"
  timeout: ${local.fluxcd.default_timeout}
  url: https://github.com/istio/istio
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "football_bets_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: football-bets
  namespace: default
spec:
  ignore: |
    /*                    # exclude all
    !/chart/football-bets # include chart dir
  interval: ${local.fluxcd.default_interval}
  ref:
    branch: "main"
  timeout: ${local.fluxcd.default_timeout}
  url: https://github.com/tiagoangelozup/football-bets
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
