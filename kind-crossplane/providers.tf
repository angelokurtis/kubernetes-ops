terraform {
  required_providers {
    helm = { source = "hashicorp/helm", version = "~> 2.17" }
    kind = { source = "tehcyx/kind", version = "~> 0.9" }
    kubectl = { source = "alekc/kubectl", version = "~> 2.1" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.37" }
    kustomization = { source = "kbst/kustomization", version = "~> 0.9" }
    null = { source = "hashicorp/null", version = "~> 3.2" }
  }
  required_version = ">= 1.9"
}

provider "helm" {
  kubernetes {
    host = kind_cluster.crossplane.endpoint

    client_certificate     = kind_cluster.crossplane.client_certificate
    client_key             = kind_cluster.crossplane.client_key
    cluster_ca_certificate = kind_cluster.crossplane.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.crossplane.endpoint

  client_certificate     = kind_cluster.crossplane.client_certificate
  client_key             = kind_cluster.crossplane.client_key
  cluster_ca_certificate = kind_cluster.crossplane.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.crossplane.endpoint

  client_certificate     = kind_cluster.crossplane.client_certificate
  client_key             = kind_cluster.crossplane.client_key
  cluster_ca_certificate = kind_cluster.crossplane.cluster_ca_certificate
}

provider "kustomization" {
  kubeconfig_raw = kind_cluster.crossplane.kubeconfig
}

provider "null" {
}
