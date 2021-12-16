resource "kubernetes_namespace" "traefik" {
  metadata { name = var.traefik_namespace }
}

resource "kubernetes_namespace" "flux" {
  metadata { name = var.flux_namespace }
}
