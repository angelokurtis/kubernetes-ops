terraform {
  required_providers {
    kind          = {
      source  = "kyma-incubator/kind"
      version = ">= 0.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.5"
    }
    helm          = {
      source  = "hashicorp/helm"
      version = ">= 2.3"
    }
    kubernetes    = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5"
    }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.flagger.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.flagger.kubeconfig_path
  }
}

provider "kustomization" {
  kubeconfig_path = kind_cluster.flagger.kubeconfig_path
}
