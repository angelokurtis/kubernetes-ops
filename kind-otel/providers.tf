terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.0.12, < 0.1.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.15.1, < 0.16.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.11.0, < 2.12.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 1.15.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  alias = "cluster_one"

  host = kind_cluster.one.endpoint

  client_certificate     = kind_cluster.one.client_certificate
  client_key             = kind_cluster.one.client_key
  cluster_ca_certificate = kind_cluster.one.cluster_ca_certificate
}

provider "kubernetes" {
  alias = "cluster_two"

  host = kind_cluster.two.endpoint

  client_certificate     = kind_cluster.two.client_certificate
  client_key             = kind_cluster.two.client_key
  cluster_ca_certificate = kind_cluster.two.cluster_ca_certificate
}

provider "kubectl" {
  alias = "cluster_one"

  host = kind_cluster.one.endpoint

  client_certificate     = kind_cluster.one.client_certificate
  client_key             = kind_cluster.one.client_key
  cluster_ca_certificate = kind_cluster.one.cluster_ca_certificate
  load_config_file       = false
}

provider "kubectl" {
  alias = "cluster_two"

  host = kind_cluster.two.endpoint

  client_certificate     = kind_cluster.two.client_certificate
  client_key             = kind_cluster.two.client_key
  cluster_ca_certificate = kind_cluster.two.cluster_ca_certificate
  load_config_file       = false
}
