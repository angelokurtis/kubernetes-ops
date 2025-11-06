resource "kubectl_manifest" "git_repository_jaeger" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: jaeger
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      ignore: |
        # exclude all
        /*
        # include charts dir
        !/charts
      interval: 60s
      ref:
        branch: v2
      timeout: 60s
      url: https://github.com/jaegertracing/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_jaeger" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: jaeger
      namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.jaeger_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: charts/jaeger
          sourceRef:
            kind: GitRepository
            name: jaeger
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.jaeger_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "jaeger_helm_values" {
  metadata {
    name      = "jaeger-helm-values"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      allInOne = {
        enabled = true
        image   = { tag = local.jaeger_latest_release }
        ingress = {
          ingressClassName = "nginx"
          enabled          = true
          hosts            = ["jaeger.${local.cluster_host}"]
          pathType         = "Prefix"
        }
      }
      storage            = { type = "memory" }
      provisionDataStore = { cassandra = false }
      agent              = { enabled = false }
      collector          = { enabled = false }
      query              = { enabled = false }
    })
  }
}

data "external" "jaeger_latest_release" {
  program = ["python3", "${path.module}/get_latest_release.py"]

  query = {
    repo = "jaegertracing/jaeger"
  }
}

locals {
  jaeger_latest_release = data.external.jaeger_latest_release.result["tag_name"]
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = "jaeger" }
}
