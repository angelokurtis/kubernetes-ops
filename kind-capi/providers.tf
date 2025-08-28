terraform {
  required_providers {
    helm          = { source = "hashicorp/helm", version = "~> 2.17" }
    kind          = { source = "tehcyx/kind", version = "~> 0.9" }
    kubectl       = { source = "alekc/kubectl", version = "~> 2.1" }
    kubernetes    = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    kustomization = { source = "kbst/kustomization", version = "~> 0.9" }
    null          = { source = "hashicorp/null", version = "~> 3.2" }
  }
  required_version = ">= 1.9"
}

provider "helm" {
  kubernetes {
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
}

provider "kubernetes" {
  host = kind_cluster.capi.endpoint

  client_certificate     = kind_cluster.capi.client_certificate
  client_key             = kind_cluster.capi.client_key
  cluster_ca_certificate = kind_cluster.capi.cluster_ca_certificate
}

provider "kustomization" {
  kubeconfig_raw = kind_cluster.capi.kubeconfig
}

provider "null" {
}
