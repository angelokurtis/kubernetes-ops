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

resource "kubernetes_cluster_role_binding_v1" "crd_readers" {
  metadata { name = "crd-readers" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_flux_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_flux_crd.metadata[0].namespace
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_apirator_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_apirator_crd.metadata[0].namespace
  }
}
