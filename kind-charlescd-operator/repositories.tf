resource "kubectl_manifest" "istio_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: istio
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://github.com/istio/istio
  ref:
    semver: "~${local.istio.version}"
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
