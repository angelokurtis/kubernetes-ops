terraform {
  required_providers {
    kind          = { source = "kyma-incubator/kind", version = ">= 0.0" }
    kubernetes    = { source = "hashicorp/kubernetes", version = ">= 2.7" }
    helm          = { source = "hashicorp/helm", version = ">= 2.4" }
    kustomization = { source = "kbst/kustomization", version = ">= 0.7" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.flux.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.flux.kubeconfig_path
  }
}

provider "kustomization" {
  kubeconfig_path = kind_cluster.flux.kubeconfig_path
}
