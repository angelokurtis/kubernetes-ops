data "kubernetes_namespace" "default" {
  metadata { name = var.namespace }

  depends_on = [ kind_cluster.openssh ]
}