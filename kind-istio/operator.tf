resource "helm_release" "istio_operator" {
  name = "istio-operator"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-operator-1.9.2.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

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
