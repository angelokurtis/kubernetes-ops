terraform {
  required_providers {
    docker     = { source = "kreuzwerker/docker", version = ">= 2.17.0, < 2.18.0" }
    kind       = { source = "tehcyx/kind", version = ">= 0.0.13, < 0.1.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.15.3, < 0.16.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.12.1, < 2.13.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 1.15.0" }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  host = kind_cluster.metrics.endpoint

  client_certificate     = kind_cluster.metrics.client_certificate
  client_key             = kind_cluster.metrics.client_key
  cluster_ca_certificate = kind_cluster.metrics.cluster_ca_certificate
}

provider "kubectl" {
  host = kind_cluster.metrics.endpoint

  client_certificate     = kind_cluster.metrics.client_certificate
  client_key             = kind_cluster.metrics.client_key
  cluster_ca_certificate = kind_cluster.metrics.cluster_ca_certificate
  load_config_file       = false
}
