resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "kubernetes_manifest" "istiocontrolplane" {
  provider = kubernetes-alpha
  manifest = yamldecode(file("${path.module}/istiocontrolplane.yaml"))

  wait_for = {
    fields = {
      "status.status" = "HEALTHY"
    }
  }

  depends_on = [
    helm_release.istio_operator,
    kubernetes_namespace.istio_system
  ]
}
