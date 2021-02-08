resource "helm_release" "horusec_manager" {
  name = "horusec-manager"
  // TODO use a proper repository
  chart = "/home/tiagoangelo/wrkspc/github.com/ZupIT/horusec/horusec-manager/deployments/helm/horusec-manager"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "env" = [
        { name = "REACT_APP_HORUSEC_ENDPOINT_API", value = "https://api-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_ANALYTIC", value = "https://analytic-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_ACCOUNT", value = "https://account-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_AUTH", value = "https://auth-horus-dev.zup.com.br" },
      ]
      "image" = { "pullPolicy" = "Always", "repository" = "horuszup/horusec-manager", "tag" = "v1.3.0" }
      "ingress" = {
        "enabled" = true
        "hosts" = [ { host = "horus-dev.zup.com.br" paths = [ "/" ] } ]
      }
      "service" = { "port" = 8080 "targetPort" = 8080 "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]

  depends_on = [
    helm_release.mongodb,
    helm_release.rabbit
  ]
}
