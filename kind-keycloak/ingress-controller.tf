resource "kubectl_manifest" "ingress_nginx_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: ingress-nginx
  namespace: ${kubernetes_namespace.ingress.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: ingress-nginx
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: ingress-nginx
        namespace: default
  values:
    controller:
      extraArgs:
        publish-status-address: 127.0.0.1
      hostPort:
        enabled: true
        ports:
          http: 80
          https: 443
      nodeSelector:
        ingress-ready: "true"
        kubernetes.io/os: linux
      publishService:
        enabled: false
      service:
        type: NodePort
YAML

  depends_on = [
    kubernetes_job_v1.wait_flux_crd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "kubernetes_namespace" "ingress" {
  metadata { name = "ingress" }
}
