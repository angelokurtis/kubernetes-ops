terraform {
  required_providers {
    kubectl    = { source = "alekc/kubectl", version = "~> 2.4" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.2" }
    helm       = { source = "hashicorp/helm", version = "~> 3.2" }
    kind       = { source = "tehcyx/kind", version = "~> 0.11" }
  }
  required_version = ">= 1.9"
}

provider "kubectl" {
  host = kind_cluster.openfga.endpoint

  client_certificate     = kind_cluster.openfga.client_certificate
  client_key             = kind_cluster.openfga.client_key
  cluster_ca_certificate = kind_cluster.openfga.cluster_ca_certificate
  load_config_file       = false
  lazy_load              = true
}

provider "kubernetes" {
  host = kind_cluster.openfga.endpoint

  client_certificate     = kind_cluster.openfga.client_certificate
  client_key             = kind_cluster.openfga.client_key
  cluster_ca_certificate = kind_cluster.openfga.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host = kind_cluster.openfga.endpoint

    client_certificate     = kind_cluster.openfga.client_certificate
    client_key             = kind_cluster.openfga.client_key
    cluster_ca_certificate = kind_cluster.openfga.cluster_ca_certificate
  }
}

provider "kind" {}
