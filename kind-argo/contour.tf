resource "helm_release" "contour" {
  name = "contour"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "contour"
  version = "4.3.2"

  values = [
    yamlencode({
      "envoy" = {
        "service" = { "type" = "NodePort" }
        "nodeSelector" = { "ingress-ready" = "true", "kubernetes.io/os" = "linux" }
        "tolerations" = {
          "effect" = "NoSchedule"
          "key" = "node-role.kubernetes.io/master"
          "operator" = "Equal"
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}
