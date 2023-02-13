terraform {
  required_providers {
    flux       = { source = "fluxcd/flux", version = ">= 0.23.0, < 1.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.8.0, < 3.0.0" }
    kind       = { source = "tehcyx/kind", version = ">= 0.0.16, < 0.1.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 2.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.17.0, < 3.0.0" }
    local      = { source = "hashicorp/local", version = ">= 2.3.0, < 3.0.0" }
    random     = { source = "hashicorp/random", version = ">= 3.4.3, < 4.0.0" }
  }
  required_version = ">= 1.0"
}

provider "flux" {}

provider "helm" {
  kubernetes {
    host = kind_cluster.kafka.endpoint

    client_certificate     = kind_cluster.kafka.client_certificate
    client_key             = kind_cluster.kafka.client_key
    cluster_ca_certificate = kind_cluster.kafka.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.kafka.endpoint

  client_certificate     = kind_cluster.kafka.client_certificate
  client_key             = kind_cluster.kafka.client_key
  cluster_ca_certificate = kind_cluster.kafka.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.kafka.endpoint

  client_certificate     = kind_cluster.kafka.client_certificate
  client_key             = kind_cluster.kafka.client_key
  cluster_ca_certificate = kind_cluster.kafka.cluster_ca_certificate
}
