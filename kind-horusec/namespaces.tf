resource "kubernetes_namespace" "horusec" {
  metadata {
    name = "horusec"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}
