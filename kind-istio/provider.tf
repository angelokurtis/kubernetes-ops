terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.7"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "2.10.0"
    }
  }
}

provider "kind" {}

provider "docker" {}

provider "kubernetes" {
  config_path = kind_cluster.istio.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.istio.kubeconfig_path
  }
}