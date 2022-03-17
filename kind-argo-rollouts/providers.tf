terraform {
  required_providers {
    kind       = { source = "kyma-incubator/kind", version = ">= 0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2" }
    helm       = { source = "hashicorp/helm", version = ">= 2" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.argo_rollouts.endpoint

  client_certificate     = kind_cluster.argo_rollouts.client_certificate
  client_key             = kind_cluster.argo_rollouts.client_key
  cluster_ca_certificate = kind_cluster.argo_rollouts.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.argo_rollouts.endpoint

    client_certificate     = kind_cluster.argo_rollouts.client_certificate
    client_key             = kind_cluster.argo_rollouts.client_key
    cluster_ca_certificate = kind_cluster.argo_rollouts.cluster_ca_certificate
  }
}

provider "kubectl" {
  host = kind_cluster.argo_rollouts.endpoint

  client_certificate     = kind_cluster.argo_rollouts.client_certificate
  client_key             = kind_cluster.argo_rollouts.client_key
  cluster_ca_certificate = kind_cluster.argo_rollouts.cluster_ca_certificate
  load_config_file       = false
}
