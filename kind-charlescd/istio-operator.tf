resource "helm_release" "istio_operator" {
  name      = "istio-operator"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://charts.kurtis.dev.br/"
  chart      = "istio-operator"
  version    = "1.7.0"

  set {
    name  = "operatorNamespace"
    value = "istio-operator"
  }

  set {
    name  = "watchedNamespaces"
    value = kubernetes_namespace.istio_system.metadata[0].name
  }

  set {
    name  = "hub"
    value = "docker.io/istio"
  }

  set {
    name  = "tag"
    value = "1.7.4-distroless"
  }
}
