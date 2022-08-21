terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.0.13, < 0.1.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.12.1, < 2.13.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.6.0, < 2.7.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.jaeger.endpoint

  client_certificate     = kind_cluster.jaeger.client_certificate
  client_key             = kind_cluster.jaeger.client_key
  cluster_ca_certificate = kind_cluster.jaeger.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.jaeger.endpoint

    client_certificate     = kind_cluster.jaeger.client_certificate
    client_key             = kind_cluster.jaeger.client_key
    cluster_ca_certificate = kind_cluster.jaeger.cluster_ca_certificate
  }
}
