resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}

resource "helm_release" "ingress_nginx" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.19"

  values = [
    <<YAML
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
  ]
}