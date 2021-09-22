terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.9"
    }
  }
  required_version = ">= 0.13"
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.argo.kubeconfig_path
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.argo.kubeconfig_path
}
