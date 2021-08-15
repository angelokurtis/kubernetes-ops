resource "helm_release" "rbac_manager" {
  name = "rbac-manager"
  namespace = kubernetes_namespace.rbac_manager.metadata[0].name

  repository = "https://charts.fairwinds.com/stable"
  chart = "rbac-manager"
  version = "1.8.2"

  values = [
    yamlencode({
      image = { tag = "v0.10.1", pullPolicy = "IfNotPresent" }
    })
  ]
}

resource "kubernetes_namespace" "rbac_manager" {
  metadata { name = "rbac-manager" }
}
