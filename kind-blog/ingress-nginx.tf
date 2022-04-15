resource "kubectl_manifest" "ingress_nginx_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: ingress-nginx
  namespace: ${kubernetes_namespace.ingress_nginx.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  values:
    controller:
      extraArgs:
        publish-status-address: "127.0.0.1"
      hostPort:
        enabled: true
        ports:
          http: 80
          https: 443
      nodeSelector:
        ingress-ready: "true"
        "kubernetes.io/os": linux
      publishService:
        enabled: false
      service:
        type: NodePort
  chart:
    spec:
      chart: ingress-nginx
      sourceRef:
        kind: HelmRepository
        name: ingress-nginx
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.ingress_nginx_helm_repository
  ]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}
