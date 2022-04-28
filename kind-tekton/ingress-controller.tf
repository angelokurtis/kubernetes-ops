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
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    controller:
      extraArgs:
        publish-status-address: ${var.load_balancer_address}
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
    kubectl_manifest.fluxcd,
    kubectl_manifest.ingress_nginx_helm_repository
  ]
}

resource "kubernetes_namespace" "ingress" {
  metadata { name = "ingress" }
}
