resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.3.4"

  values = [
    yamlencode({
      image     = { tag = "2.5.3" }
      ports     = {
        traefik   = { expose = true, nodePort = 32090 }
        web       = { nodePort = 32080 }
        websecure = { nodePort = 32443 }
      }
      providers = {
        kubernetesCRD     = { namespaces = ["default", kubernetes_namespace.ingress.metadata[0].name] }
        kubernetesIngress = { namespaces = ["default", kubernetes_namespace.ingress.metadata[0].name] }
      }
      service   = { type = "NodePort" }
    })
  ]
}

resource "kubernetes_namespace" "ingress" {
  metadata { name = "ingress" }
}
