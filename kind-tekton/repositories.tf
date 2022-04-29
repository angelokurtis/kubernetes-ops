resource "kubectl_manifest" "ingress_nginx_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ingress-nginx
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://kubernetes.github.io/ingress-nginx
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "tektoncd_operator_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: tektoncd-operator
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://github.com/tektoncd/operator
  ref:
    semver: "~${local.tektoncd.operator.version}"
  ignore: |
    # exclude all
    /*
    # include deploy dir
    !/config
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
