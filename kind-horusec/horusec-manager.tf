resource "helm_release" "horusec_manager" {
  name = "horusec-manager"
  // TODO use a proper repository
  chart = "/home/tiagoangelo/wrkspc/github.com/ZupIT/horusec/horusec-manager/deployments/helm/horusec-manager"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  depends_on = [
    helm_release.mongodb,
    helm_release.rabbit
  ]
}
