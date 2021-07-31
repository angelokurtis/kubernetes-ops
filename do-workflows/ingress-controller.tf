locals {
  ingress_ip = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  cluster_host = "${join("", formatlist("%02x", split(".", local.ingress_ip)))}.nip.io"
}

resource "helm_release" "nginx" {
  name = "nginx"
  namespace = kubernetes_namespace.ingress_controller.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "3.34.0"

  set {
    name = "fullnameOverride"
    value = "nginx"
  }
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name = "nginx-controller"
    namespace = kubernetes_namespace.ingress_controller.metadata[0].name
  }

  depends_on = [ helm_release.nginx ]
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata { name = "ingress-controller" }
}
