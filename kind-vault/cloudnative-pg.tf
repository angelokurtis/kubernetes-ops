resource "kubectl_manifest" "helm_repository_cnpg" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: cnpg
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://cloudnative-pg.github.io/charts
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_cnpg_operator" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: cnpg-operator
      namespace: ${kubernetes_namespace_v1.cnpg.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.cnpg_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: cloudnative-pg
          sourceRef:
            kind: HelmRepository
            name: cnpg
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      install:
        crds: CreateReplace
      upgrade:
        crds: CreateReplace
      interval: 60s
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_cnpg" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: cnpg
      namespace: ${kubernetes_namespace_v1.cnpg.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.cnpg_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: cluster
          sourceRef:
            kind: HelmRepository
            name: cnpg
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.cnpg_helm_values.metadata[0].name}
      interval: 60s
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubectl_manifest.helm_release_cnpg_operator]
}

resource "kubernetes_config_map_v1" "cnpg_helm_values" {
  metadata {
    name      = "cnpg-helm-values"
    namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      type    = "postgresql"
      mode    = "standalone"
      backups = { enabled = false }
      cluster = {
        enablePDB = false
        instances = 1
        initdb    = { database = "app", owner = "app" }
        resources = {
          limits   = { cpu = "500m", memory = "512Mi" }
          requests = { cpu = "100m", memory = "256Mi" }
        }
        storage = { size = "5Gi" }
      }
    })
  }
}

resource "kubernetes_namespace_v1" "cnpg" {
  metadata { name = "cnpg" }
}
