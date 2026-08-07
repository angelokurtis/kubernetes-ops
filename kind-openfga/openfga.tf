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
  dsl = file("model.fga")
}

resource "openfga_authorization_model" "example" {
  store_id = openfga_store.development.id

  model_json = data.openfga_authorization_model_document.example.result
}

# These tuples establish that the clusters belong to organization:acme
resource "openfga_relationship_tuple" "production_organization" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "organization:acme"
  relation = "organization"
  object   = "cluster:production"
}

resource "openfga_relationship_tuple" "staging_organization" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "organization:acme"
  relation = "organization"
  object   = "cluster:staging"
}

resource "openfga_relationship_tuple" "development_organization" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "organization:acme"
  relation = "organization"
  object   = "cluster:development"
}

# Alice can view every cluster
resource "openfga_relationship_tuple" "alice_view_clusters" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "user:alice"
  relation = "view_clusters"
  object   = "organization:acme"
}

# Alice can connect to every cluster
resource "openfga_relationship_tuple" "alice_connect_clusters" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "user:alice"
  relation = "connect_clusters"
  object   = "organization:acme"
}

# Bob can configure only production
resource "openfga_relationship_tuple" "bob_modify_production" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "user:bob"
  relation = "modify"
  object   = "cluster:production"
}

# Because provisioning happens before a cluster exists, the capability belongs to the organization
resource "openfga_relationship_tuple" "alice_create_clusters" {
  store_id               = openfga_authorization_model.example.store_id
  authorization_model_id = openfga_authorization_model.example.id

  user     = "user:alice"
  relation = "create_clusters"
  object   = "organization:acme"
}

resource "kubernetes_namespace_v1" "openfga" {
  metadata { name = "openfga" }
}
