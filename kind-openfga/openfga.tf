resource "kubectl_manifest" "helm_repository_openfga" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: openfga
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://openfga.github.io/helm-charts
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_openfga" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: openfga
      namespace: ${kubernetes_namespace_v1.openfga.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.openfga_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: openfga
          sourceRef:
            kind: HelmRepository
            name: openfga
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.openfga_helm_values.metadata[0].name}
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

resource "kubernetes_config_map_v1" "openfga_helm_values" {
  metadata {
    name      = "openfga-helm-values"
    namespace = kubernetes_namespace_v1.openfga.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      playground = { enabled = false }
      ingress = {
        annotations = {}
        className   = "traefik"
        enabled     = true
        hosts = [
          {
            host  = "openfga.${local.cluster_host}"
            paths = [{ path = "/", pathType = "ImplementationSpecific" }]
          },
        ]
      }
    })
  }
}

resource "openfga_store" "development" {
  name = "development"

  depends_on = [kubectl_manifest.helm_release_openfga]
}

data "openfga_authorization_model_document" "example" {
  dsl = <<EOT
model
  schema 1.1

type user

type document
  relations
    define viewer: [user]
  EOT
}

resource "openfga_authorization_model" "example" {
  store_id = openfga_store.development.id

  model_json = data.openfga_authorization_model_document.example.result
}

resource "openfga_relationship_tuple" "example" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "user:user-1"
  relation = "viewer"
  object   = "document:document-1"
}

resource "kubernetes_namespace_v1" "openfga" {
  metadata { name = "openfga" }
}
