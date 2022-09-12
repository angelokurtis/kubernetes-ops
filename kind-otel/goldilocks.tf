locals {
  goldilocks = {
    image     = { pullPolicy = "IfNotPresent" }
    dashboard = {
      replicaCount = 1
      ingress      = {
        enabled          = true,
        ingressClassName = "nginx"
        hosts            = [
          { host = "goldilocks.${local.cluster_host}", paths = [{ path = "/", type = "ImplementationSpecific" }] }
        ],
      }
    }
  }
}

resource "kubernetes_namespace_v1" "goldilocks" {
  metadata { name = "goldilocks" }
}
