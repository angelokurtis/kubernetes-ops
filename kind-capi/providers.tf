terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = "~> 0.9" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    helm       = { source = "hashicorp/helm", version = "~> 2.17" }
    kubectl    = { source = "alekc/kubectl", version = "~> 2.1" }
  }
  required_version = ">= 1.9"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.capi.endpoint

  client_certificate     = kind_cluster.capi.client_certificate
  client_key             = kind_cluster.capi.client_key
  cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.capi.endpoint

    client_certificate     = kind_cluster.capi.client_certificate
    client_key             = kind_cluster.capi.client_key
    cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
  }
}


provider "kubectl" {
  host = kind_cluster.capi.endpoint

  client_certificate     = kind_cluster.capi.client_certificate
  client_key             = kind_cluster.capi.client_key
  cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
  load_config_file       = false
}
