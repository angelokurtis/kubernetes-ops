resource "helm_release" "kibana" {
  name      = "kibana"
  namespace = kubernetes_namespace.elk.metadata[0].name

  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.15.0"

  set {
    name  = "fullnameOverride"
    value = "kibana"
  }

  values = [
    yamlencode({
      ingress = {
        enabled     = true
        annotations = { "kubernetes.io/ingress.class" = "nginx" }
        hosts       = [
          {
            host  = "kibana.${local.cluster_domain}"
            paths = [{ path = "/" }]
          }
        ]
      }
    })
  ]

  depends_on = [helm_release.elasticsearch]
}
