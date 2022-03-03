resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name   = local.flux.namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = "v${local.flux.version}"
    }
  }
}

resource "kubernetes_namespace" "rbac_manager" {
  metadata { name = local.rbac_manager.namespace }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}
