terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.7"
    }
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.horusec.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.horusec.kubeconfig_path
  }
}