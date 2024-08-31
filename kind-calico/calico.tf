resource "helm_release" "tigera_operator" {
  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  version    = "3.28.1"

  name      = "calico"
  namespace = kubernetes_namespace.tigera_operator.metadata[0].name
}

resource "kubernetes_namespace" "tigera_operator" {
  metadata { name = "tigera-operator" }
}
