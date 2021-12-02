resource "helm_release" "elasticsearch" {
  name      = "elasticsearch"
  namespace = kubernetes_namespace.elastic.metadata[0].name

  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.15.0"

  set {
    name  = "nameOverride"
    value = "elasticsearch"
  }

  values = [
    yamlencode({
      # Permit co-located instances.
      antiAffinity        = "soft",
      # Shrink default JVM heap.
      esJavaOpts          = "-Xmx128m -Xms128m",
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

resource "kubernetes_namespace" "elastic" {
  metadata { name = "elastic" }
}
