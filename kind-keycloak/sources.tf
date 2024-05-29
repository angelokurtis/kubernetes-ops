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

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "ingress_nginx_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ingress-nginx
  namespace: default
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://kubernetes.github.io/ingress-nginx
YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}
