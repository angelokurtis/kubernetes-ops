terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.2.0, < 0.3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.21.1, < 4.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.10.1, < 3.0.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 2.0.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.apirator.endpoint

  client_certificate     = kind_cluster.apirator.client_certificate
  client_key             = kind_cluster.apirator.client_key
  cluster_ca_certificate = kind_cluster.apirator.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.apirator.endpoint

    client_certificate     = kind_cluster.apirator.client_certificate
    client_key             = kind_cluster.apirator.client_key
    cluster_ca_certificate = kind_cluster.apirator.cluster_ca_certificate
  }
}


provider "kubectl" {
  host = kind_cluster.apirator.endpoint

  client_certificate     = kind_cluster.apirator.client_certificate
  client_key             = kind_cluster.apirator.client_key
  cluster_ca_certificate = kind_cluster.apirator.cluster_ca_certificate
  load_config_file       = false
}