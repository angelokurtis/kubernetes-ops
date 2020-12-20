resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  chart = "${path.module}/manifests/charts/base"
  name = "istio-base"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
}

resource "helm_release" "istiod" {
  chart = "${path.module}/manifests/charts/istio-control/istio-discovery"
  name = "istiod"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  values = [
    yamlencode({
      global = {
        hub = "docker.io/istio"
        tag = "1.8.1"
        jwtPolicy = "first-party-jwt"
      }
    })
  ]

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  chart = "${path.module}/manifests/charts/gateways/istio-ingress"
  name = "istio-ingress"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  values = [
    yamlencode({
      global = {
        hub = "docker.io/istio"
        tag = "1.8.1"
        jwtPolicy = "first-party-jwt"
      }
    })
  ]

  depends_on = [
    helm_release.istio_base
  ]
}
