resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_controller.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "3.34.0"

  values = [
    file("${path.module}/ingress-controller.yaml")
  ]
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata {
    name = "ingress-controller"
  }
}