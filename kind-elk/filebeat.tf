resource "helm_release" "filebeat" {
  name      = "filebeat"
  namespace = kubernetes_namespace.elk.metadata[0].name

  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  version    = "7.15.0"

  set {
    name  = "nameOverride"
    value = "filebeat"
  }

  depends_on = [helm_release.elasticsearch]
}
