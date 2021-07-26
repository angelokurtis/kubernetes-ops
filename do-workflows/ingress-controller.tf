resource "helm_release" "nginx" {
  name = "nginx"
  namespace = kubernetes_namespace.ingress_controller.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "3.34.0"
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata { name = "ingress-controller" }
}
