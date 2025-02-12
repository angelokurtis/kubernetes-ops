terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.7.0, < 1.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.35.1, < 4.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.17.0, < 3.0.0" }
    kubectl    = { source = "alekc/kubectl", version = ">= 2.1.3, < 3.0.0" }
  }
  required_version = ">= 1.0"
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
