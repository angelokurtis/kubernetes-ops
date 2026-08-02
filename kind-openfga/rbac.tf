resource "kubernetes_cluster_role_v1" "crd_reader" {
  metadata {
    name = "crd-reader"
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "list", "watch"]
  }
}
