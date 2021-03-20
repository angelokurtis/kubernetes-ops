terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.7"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.4.2"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "2.10.0"
    }
  }
  required_version = ">= 0.13"
}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.istio.kubeconfig_path
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.istio.kubeconfig_path
}

provider "kustomization" {
  kubeconfig_path = kind_cluster.istio.kubeconfig_path
}
