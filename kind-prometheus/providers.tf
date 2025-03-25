terraform {
  required_providers {
    kubectl = { source = "alekc/kubectl", version = ">= 2.1.3, < 3.0.0" }
    helm = { source = "hashicorp/helm", version = ">= 2.17.0, < 3.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.36.0, < 4.0.0" }
    kind = { source = "tehcyx/kind", version = ">= 0.8.0, < 1.0.0" }
  }
  required_version = ">= 1.0"
}

provider "helm" {
  kubernetes {
    host = kind_cluster.metrics.endpoint

    client_certificate     = kind_cluster.metrics.client_certificate
    client_key             = kind_cluster.metrics.client_key
    cluster_ca_certificate = kind_cluster.metrics.cluster_ca_certificate
  }
}

provider "kubectl" {
  host = kind_cluster.metrics.endpoint

  client_certificate     = kind_cluster.metrics.client_certificate
  client_key             = kind_cluster.metrics.client_key
  cluster_ca_certificate = kind_cluster.metrics.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.metrics.endpoint

  client_certificate     = kind_cluster.metrics.client_certificate
  client_key             = kind_cluster.metrics.client_key
  cluster_ca_certificate = kind_cluster.metrics.cluster_ca_certificate
}

provider "kind" {}
