terraform {
  required_providers {
    external   = { source = "hashicorp/external", version = "~> 2.4" }
    helm       = { source = "hashicorp/helm", version = "~> 3.3" }
    kind       = { source = "tehcyx/kind", version = "~> 0.13" }
    kubectl    = { source = "alekc/kubectl", version = "~> 3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.4" }
    null       = { source = "hashicorp/null", version = "~> 3.3" }
  }
  required_version = ">= 1.9"
}

provider "external" {
}

provider "helm" {
  kubernetes = {
    host = kind_cluster.capi.endpoint

    client_certificate     = kind_cluster.capi.client_certificate
    client_key             = kind_cluster.capi.client_key
    cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.capi.endpoint

  client_certificate     = kind_cluster.capi.client_certificate
  client_key             = kind_cluster.capi.client_key
  cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
  load_config_file       = false
  lazy_load              = true
}

provider "kubernetes" {
  host = kind_cluster.capi.endpoint

  client_certificate     = kind_cluster.capi.client_certificate
  client_key             = kind_cluster.capi.client_key
  cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
}

provider "null" {
}
