terraform {
  required_providers {
    kind       = { source = "kyma-incubator/kind", version = ">= 0.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.11" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.8" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.13" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  host = kind_cluster.rbac.endpoint

  client_certificate     = kind_cluster.rbac.client_certificate
  client_key             = kind_cluster.rbac.client_key
  cluster_ca_certificate = kind_cluster.rbac.cluster_ca_certificate
}

provider "kubectl" {
  host = kind_cluster.rbac.endpoint

  client_certificate     = kind_cluster.rbac.client_certificate
  client_key             = kind_cluster.rbac.client_key
  cluster_ca_certificate = kind_cluster.rbac.cluster_ca_certificate
  load_config_file       = false
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.rbac]
}
