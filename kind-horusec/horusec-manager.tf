resource "helm_release" "manager" {
  name = "manager"
  // TODO use a proper repository
  chart = "${var.horusec_project_path}/horusec-manager/deployments/helm/horusec-manager"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "fullnameOverride" = "manager"
      "env" = [
        { name = "REACT_APP_HORUSEC_ENDPOINT_API", value = "http:\\\\/\\\\/api-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_ANALYTIC", value = "http:\\\\/\\\\/analytic-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_ACCOUNT", value = "http:\\\\/\\\\/account-horus-dev.zup.com.br" },
        { name = "REACT_APP_HORUSEC_ENDPOINT_AUTH", value = "http:\\\\/\\\\/auth-horus-dev.zup.com.br" },
      ]
      "image" = { "pullPolicy" = "Always", "repository" = "horuszup/horusec-manager", "tag" = "v1.7.1" }
      "ingress" = {
        "enabled" = true
        "hosts" = [ { host = "horus-dev.zup.com.br", paths = [ "/"] } ]
        "annotations" = { "kubernetes.io/ingress.class" = "nginx" }
      }
      "service" = { "port" = 8080, "targetPort" = 8080, "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]
}
