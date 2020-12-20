terraform {
  required_providers {
    kind = {
      source = "unicell/kind"
      version = "0.0.2-u2"
    }
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.istio.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.istio.kubeconfig_path
  }
}