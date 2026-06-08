resource "kubectl_manifest" "helm_repository_hashicorp" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: hashicorp
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://helm.releases.hashicorp.com
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_vault" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: vault
      namespace: ${kubernetes_namespace_v1.vault.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.vault_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: vault
          sourceRef:
            kind: HelmRepository
            name: hashicorp
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.vault_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "vault_helm_values" {
  metadata {
    name      = "vault-helm-values"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      server = { dev = { enabled = true } }
    })
  }
}

resource "kubernetes_namespace_v1" "vault" {
  metadata { name = "vault" }
}
