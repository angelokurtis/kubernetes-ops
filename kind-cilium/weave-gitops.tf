resource "kubectl_manifest" "git_repository_weave_gitops" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: weave-gitops
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://github.com/weaveworks/weave-gitops
      ref:
        semver: ^0.28.0
      ignore: |
        # exclude all
        /*
        # include charts dir
        !/charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_gitops_server" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: gitops-server
      namespace: ${kubernetes_namespace.weave_gitops.metadata[0].name}
    spec:
      chart:
        spec:
          chart: charts/gitops-server
          sourceRef:
            kind: GitRepository
            name: weave-gitops
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.gitops_server.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "gitops_server" {
  metadata {
    name      = "gitops-server"
    namespace = kubernetes_namespace.weave_gitops.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      networkPolicy = { create = false }
      adminUser     = {
        create       = true
        username     = "admin"
        passwordHash = "$2a$12$7CuWwmxV.JpdUcR.99nWtuH4662RLgcNUoP2XZolBkExz.1MJsQiK"
      }
      ingress = {
        className = "nginx"
        enabled   = true
        hosts     = [
          {
            host  = "gitops.${local.cluster_host}"
            paths = [{ path = "/", pathType = "ImplementationSpecific" }]
          },
        ]
      }
    })
  }
}

resource "kubernetes_namespace" "weave_gitops" {
  metadata { name = "weave-gitops" }
}
