terraform {
  required_providers {
    kind       = { source = "kyma-incubator/kind", version = ">= 0" }
    flux       = { source = "fluxcd/flux", version = ">= 0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  host = kind_cluster.keycloak_cluster.endpoint

  client_certificate     = kind_cluster.keycloak_cluster.client_certificate
  client_key             = kind_cluster.keycloak_cluster.client_key
  cluster_ca_certificate = kind_cluster.keycloak_cluster.cluster_ca_certificate
}

provider "kubectl" {
  host = kind_cluster.keycloak_cluster.endpoint

  client_certificate     = kind_cluster.keycloak_cluster.client_certificate
  client_key             = kind_cluster.keycloak_cluster.client_key
  cluster_ca_certificate = kind_cluster.keycloak_cluster.cluster_ca_certificate
  load_config_file       = false
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.keycloak_cluster]
}
