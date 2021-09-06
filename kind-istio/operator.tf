resource "helm_release" "istio_operator" {
  name = "istio-operator"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://charts.kurtis.dev.br/"
  chart = "istio-operator"
  version = "1.9.1"

  set {
    name = "tag"
    value = "1.9.2-distroless"
  }

  set {
    name = "operatorNamespace"
    value = "istio-operator"
  }

  set {
    name = "watchedNamespaces"
    value = kubernetes_namespace.istio_system.metadata[0].name
  }
}
