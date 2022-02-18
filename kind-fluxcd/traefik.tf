resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = kubernetes_namespace.traefik.metadata[0].name

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.14.1"

  values = [
    yamlencode({
      image = { repository = "traefik", tag = "2.6.1" }
      ports = {
        traefik   = { expose = true, nodePort = 32090 }
        web       = { nodePort = 32080 }
        websecure = { nodePort = 32443 }
      }
      ingressClass = { enabled = true, isDefaultClass = true }
      providers    = {
        kubernetesCRD     = { namespaces = ["default", kubernetes_namespace.traefik.metadata[0].name] }
        kubernetesIngress = { namespaces = ["default", kubernetes_namespace.traefik.metadata[0].name] }
      }
      service = { type = "NodePort" }
    })
  ]
}
