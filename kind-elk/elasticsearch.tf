resource "helm_release" "elasticsearch" {
  name      = "elasticsearch"
  namespace = kubernetes_namespace.elk.metadata[0].name

  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.15.0"

  set {
    name  = "nameOverride"
    value = "elasticsearch"
  }

  values = [
    yamlencode({
      replicas            = 2
      # Permit co-located instances.
      antiAffinity        = "soft",
      # Allocate smaller chunks of memory per pod.
      resources           = {
        limits   = { cpu = "1000m", memory = "512M" }
        requests = { cpu = "100m", memory = "512M" }
      }
      # Request smaller persistent volumes.
      volumeClaimTemplate = {
        accessModes      = ["ReadWriteOnce"]
        resources        = { requests = { storage = "100M" } }
        storageClassName = "standard"
      }
    })
  ]
}

resource "kubernetes_namespace" "elk" {
  metadata { name = "elk" }
}
